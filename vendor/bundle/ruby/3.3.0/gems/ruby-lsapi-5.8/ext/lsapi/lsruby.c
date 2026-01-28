
#include "ruby.h"

#if defined( RUBY_18 )
#include "util.h"
#include "version.h"
#elif defined( RUBY_VERSION_CODE ) && RUBY_VERSION_CODE < 180
#include "util.h"
#else
#include <ruby/util.h>
#include <ruby/version.h>
#endif

#include "lsapilib.h"
#include <errno.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <signal.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>


#ifndef RUBY_API_VERSION_CODE
#define RUBY_API_VERSION_CODE (RUBY_API_VERSION_MAJOR*10000+RUBY_API_VERSION_MINOR*100+RUBY_API_VERSION_TEENY)
#endif

/* RUBY_EXTERN VALUE ruby_errinfo; */
RUBY_EXTERN VALUE rb_stdin;
RUBY_EXTERN VALUE rb_stdout;
#if defined( RUBY_VERSION_CODE ) && RUBY_VERSION_CODE < 180
RUBY_EXTERN VALUE rb_defout;
#endif

static VALUE orig_stdin;
static VALUE orig_stdout;
static VALUE orig_stderr;
#if defined( RUBY_VERSION_CODE ) && RUBY_VERSION_CODE < 180
static VALUE orig_defout;
#endif
static VALUE orig_env;

static VALUE env_copy;

static VALUE lsapi_env;

static int MAX_BODYBUF_LENGTH = (10 * 1024 * 1024);

#if RUBY_API_VERSION_CODE >= 20700
# if defined rb_tainted_str_new
#  undef rb_tainted_str_new
# endif
# define rb_tainted_str_new(p,l)  rb_str_new((p),(l))
#endif

/* static VALUE lsapi_objrefs; */

typedef struct lsapi_data
{
    LSAPI_Request * req;
    VALUE           env;
    ssize_t      (* fn_write)( LSAPI_Request *, const char * , size_t );
}lsapi_data;

static VALUE cLSAPI;

static VALUE s_req = Qnil;
static lsapi_data * s_req_data;

static VALUE s_req_stderr = Qnil;
static lsapi_data * s_stderr_data;
static pid_t s_pid = 0;

typedef struct lsapi_body
{
    char        *bodyBuf;  //we put small one into memory, otherwise, into a memory mapping file, and we still use the bodyBuf to access this mapping
    int	        bodyLen;	//expected length got form content-length
    int	        bodyCurrentLen;	//current length by read() readBodyToReqBuf
    int	        curPos;
}lsapi_body;

static lsapi_body	s_body;
static char sTempFile[1024] = {0};

/*
 * static void lsapi_ruby_setenv(const char *name, const char *value)
 * {
 *    if (!name) return;
 * 
 *    if (value && *value)
 *	    ruby_setenv(name, value);
 *    else
 *        ruby_unsetenv(name);
 } *        *
 */


static void lsapi_mark( lsapi_data * data )
{
    rb_gc_mark( data->env );
}
/*
 * static void lsapi_free_data( lsapi_data * data )
 * {
 *   free( data );
 } *        *
 */
static int add_env_rails( const char * pKey, int keyLen, const char * pValue, int valLen,
                          void * arg )
{
    char * p;
    int len;
    /* Fixup some environment variables for rails */
    switch( *pKey )
    {
        case 'Q':
            if ( strcmp( pKey, "QUERY_STRING" ) == 0 )
            {
                if ( !*pValue )
                    return 1;
            }
            break;
        case 'R':
            if (( *(pKey+8) == 'U' )&&( strcmp( pKey, "REQUEST_URI" ) == 0 ))
            {
                p = strchr( pValue, '?' );
                if ( p )
                {
                    len = valLen - ( p - pValue ) - 1;
                    /* 
                     *                valLen = p - pValue;
                     *p++ = 0;
                     */
                }
                else
                {
                    p = (char *)pValue + valLen;
                    len = 0;
                }
                rb_hash_aset( lsapi_env,rb_tainted_str_new("PATH_INFO", 9),
                              rb_tainted_str_new(pValue, p - pValue));
                rb_hash_aset( lsapi_env,rb_tainted_str_new("REQUEST_PATH", 12),
                              rb_tainted_str_new(pValue, p - pValue));
                if ( *p == '?' )
                    ++p;
                rb_hash_aset( lsapi_env,rb_tainted_str_new("QUERY_STRING", 12),
                rb_tainted_str_new(p, len));
            }
            break;
        case 'S':
            if ( strcmp( pKey, "SCRIPT_NAME" ) == 0 )
            {
                pValue = "/";
                valLen = 1;
            }
            break;
        case 'P':
            if ( strcmp( pKey, "PATH_INFO" ) == 0 )
                return 1;
        default:
            break;
    }
    
    /* lsapi_ruby_setenv(pKey, pValue ); */
    
    rb_hash_aset( lsapi_env,rb_tainted_str_new(pKey, keyLen),
                  rb_tainted_str_new(pValue, valLen));
    return 1;
}

static int add_env_no_fix( const char * pKey, int keyLen, const char * pValue, int valLen,
                           void * arg )
{
    rb_hash_aset( lsapi_env,rb_tainted_str_new(pKey, keyLen),
                  rb_tainted_str_new(pValue, valLen));
    return 1;
}

typedef int (*fn_add_env)( const char * pKey, int keyLen, const char * pValue, int valLen,
                           void * arg );

fn_add_env s_fn_add_env = add_env_no_fix;

static void clear_env()
{
    /* rb_funcall( lsapi_env, rb_intern( "clear" ), 0 ); */
    rb_funcall( lsapi_env, rb_intern( "replace" ), 1, env_copy );
}

static void setup_cgi_env( lsapi_data * data )
{
    clear_env();
    
    LSAPI_ForeachHeader_r( data->req, s_fn_add_env, data );
    LSAPI_ForeachEnv_r( data->req, s_fn_add_env, data );
}

static VALUE lsapi_s_accept( VALUE self )
{
    int pid;
    if ( LSAPI_Prefork_Accept_r( &g_req ) == -1 )
        return Qnil;
    else
    {
        if (s_body.bodyBuf != NULL)
            free (s_body.bodyBuf);
        
        s_body.bodyBuf = NULL;
        s_body.bodyLen = -1;
        s_body.bodyCurrentLen = 0;
        s_body.curPos = 0;    
        
        pid = getpid();
        if ( pid != s_pid )
        {
            s_pid = pid;
            rb_funcall( Qnil, rb_intern( "srand" ), 0 );
        }
        
        setup_cgi_env( s_req_data );
        return s_req;
    }
}


static VALUE lsapi_s_accept_new_conn(VALUE self)
{
    if (LSAPI_Accept_Before_Fork(&g_req) == -1 )
        return Qnil;
    else
        return s_req;
}


static VALUE lsapi_s_postfork_child(VALUE self)
{
    LSAPI_Postfork_Child(&g_req);
    return s_req;
}


static VALUE lsapi_s_postfork_parent(VALUE self)
{
    LSAPI_Postfork_Parent(&g_req);
    return s_req;
}


/*
 * static int chdir_file( const char * pFile )
 * {
 *    char * p = strrchr( pFile, '/' );
 *    int ret;
 *    if ( !p )
 *        return -1;
 *p = 0;
 ret = chdir( pFile );
 *p = '/';
 return ret;
 }
 */

static VALUE lsapi_eval_string_wrap(VALUE self, VALUE str)
{
#if RUBY_API_VERSION_CODE < 20700
    if (rb_safe_level() >= 4)
    {
        Check_Type(str, T_STRING);
    }
    else
#endif
    {
        SafeStringValue(str);
    }
    return rb_eval_string_wrap(StringValuePtr(str), NULL);
}

static VALUE lsapi_process( VALUE self )
{
/*    lsapi_data *data;
    const char * pScriptPath;
    Data_Get_Struct(self,lsapi_data, data);
    pScriptPath = LSAPI_GetScriptFileName_r( data->req );
*/
    /*
     *   if ( chdir_file( pScriptPath ) == -1 )
     *   {
     *       lsapi_send_error( 404 );
     *   }
     *   rb_load_file( pScriptPath );
     */
    return Qnil;
}


static VALUE lsapi_putc(VALUE self, VALUE c)
{
    char ch = NUM2CHR(c);
    lsapi_data *data;
    Data_Get_Struct(self,lsapi_data, data);
    if ( (*data->fn_write)( data->req, &ch, 1 ) == 1 )
        return c;
    else
        return INT2NUM( EOF );
}


static VALUE lsapi_write( VALUE self, VALUE str )
{
    lsapi_data *data;
    int len;
    Data_Get_Struct(self,lsapi_data, data);
    /*    len = LSAPI_Write_r( data->req, RSTRING_PTR(str), RSTRING_LEN(str) ); */
    if (TYPE(str) != T_STRING)
        str = rb_obj_as_string(str);
    len = (*data->fn_write)( data->req, RSTRING_PTR(str), RSTRING_LEN(str) );
    return INT2NUM( len );
}

static VALUE lsapi_print( int argc, VALUE *argv, VALUE out )
{
    int i;
    VALUE line;
    
    /* if no argument given, print `$_' */
    if (argc == 0)
    {
        argc = 1;
        line = rb_lastline_get();
        argv = &line;
    }
    for (i = 0; i<argc; i++)
    {
        if (!NIL_P(rb_output_fs) && i>0)
        {
            lsapi_write(out, rb_output_fs);
        }
        switch (TYPE(argv[i]))
        {
            case T_NIL:
                lsapi_write(out, rb_str_new2("nil"));
                break;
            default:
                lsapi_write(out, argv[i]);
                break;
        }
    }
    if (!NIL_P(rb_output_rs))
    {
        lsapi_write(out, rb_output_rs);
    }
    
    return Qnil;
}

static VALUE lsapi_printf(int argc, VALUE *argv, VALUE out)
{
    lsapi_write(out, rb_f_sprintf(argc, argv));
    return Qnil;
}

static VALUE lsapi_puts _((int, VALUE*, VALUE));

#if RUBY_API_VERSION_CODE >= 10900
static VALUE lsapi_puts_ary(VALUE ary, VALUE out, int recur )
{
    VALUE tmp;
    long i;
    
    if (recur)
    {
        tmp = rb_str_new2("[...]");
        rb_io_puts(1, &tmp, out);
        return Qnil;
    }
    for (i=0; i<RARRAY_LEN(ary); i++) 
    {
        tmp = RARRAY_PTR(ary)[i];
        rb_io_puts(1, &tmp, out);
    }
    return Qnil;
    
}
#else
static VALUE lsapi_puts_ary(VALUE ary, VALUE out)
{
    VALUE tmp;
    int i;
    
    for (i=0; i<RARRAY_LEN(ary); i++)
    {
        tmp = RARRAY_PTR(ary)[i];
        if (rb_inspecting_p(tmp))
        {
            tmp = rb_str_new2("[...]");
        }
        lsapi_puts(1, &tmp, out);
    }
    return Qnil;
}
#endif

static VALUE lsapi_puts(int argc, VALUE *argv, VALUE out)
{
    int i;
    VALUE line;
    
    /* if no argument given, print newline. */
    if (argc == 0)
    {
        lsapi_write(out, rb_default_rs);
        return Qnil;
    }
    for (i=0; i<argc; i++)
    {
        switch (TYPE(argv[i]))
        {
            case T_NIL:
                line = rb_str_new2("nil");
                break;
            case T_ARRAY:
#if RUBY_API_VERSION_CODE >= 10900
                rb_exec_recursive(lsapi_puts_ary, argv[i], out);
#else
                rb_protect_inspect(lsapi_puts_ary, argv[i], out);
#endif
                continue;
            default:
                line = argv[i];
                break;
        }
        line = rb_obj_as_string(line);
        lsapi_write(out, line);
        if (*( RSTRING_PTR(line) + RSTRING_LEN(line) - 1 ) != '\n')
        {
            lsapi_write(out, rb_default_rs);
        }
    }
    
    return Qnil;
}


static VALUE lsapi_addstr(VALUE out, VALUE str)
{
    lsapi_write(out, str);
    return out;
}

static VALUE lsapi_flush( VALUE self )
{
    /*
     *    lsapi_data *data;
     *    Data_Get_Struct(self,lsapi_data, data);
     */
    LSAPI_Flush_r( &g_req ); 
    return Qnil;
}

static VALUE lsapi_getc( VALUE self )
{
    int ch;
    /*
     *    lsapi_data *data;
     *    Data_Get_Struct(self,lsapi_data, data);
     */
#if RUBY_API_VERSION_CODE < 20700
    if (rb_safe_level() >= 4 && !OBJ_TAINTED(self))
    {
        rb_raise(rb_eSecurityError, "Insecure: operation on untainted IO");
    }
#endif
    ch = LSAPI_ReqBodyGetChar_r( &g_req );
    if ( ch == EOF )
        return Qnil;
    return INT2NUM( ch );
}

static inline int isBodyWriteToFile()
{
    return ((s_body.bodyLen >= MAX_BODYBUF_LENGTH)? (1): (0));
}

//create a temp file and open it, if failed, fd = -1
static inline int createTempFile()
{
    int fd = -1;
    char *sfn = strdup(sTempFile);
    
    if ((fd = mkstemp(sfn)) == -1)
    {
        fprintf(stderr, "%s: %s\n", sfn, strerror(errno));
    }
    else
        unlink(sfn);
    
    free(sfn);
    return fd;
}

//return 1 if error occured!
//if already created, always OK (0)
static int createBodyBuf()
{
    int fd = -1;
    if (s_body.bodyLen == -1)
    {
        s_body.bodyLen = LSAPI_GetReqBodyLen_r(&g_req);
        //Error if get a zeor length, should not happen 
        if (s_body.bodyLen < 0)
        {
            //Wrong bode length will be treated as 0
            s_body.bodyLen = 0;
        }
        
        if (s_body.bodyLen > 0) 
        {
            if (isBodyWriteToFile())
            {
                //create file mapping
                fd = createTempFile();
                if (fd == -1)
                {
                    return 1;
                }
                if (ftruncate(fd, s_body.bodyLen) == 0)
                {
                    perror("ftruncate() failed. \n");
                    close(fd);
                    return 1;
                }
                s_body.bodyBuf = mmap(NULL, s_body.bodyLen, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
                if (s_body.bodyBuf == MAP_FAILED)
                {
                    perror("File mapping failed. \n");
                    close(fd);
                    return 1;
                }
                close(fd);  //close since needn't it anymore
            }
            else
            {
                s_body.bodyBuf = (char *)calloc(s_body.bodyLen, sizeof(char));
                if (s_body.bodyBuf == NULL)
                {
                    perror("Memory calloc error");
                    return 1;
                }
            }
        }
    }

    return 0;   
}

static inline int isAllBodyRead()
{
    return (s_body.bodyCurrentLen < s_body.bodyLen)? 0 : 1;
}

static inline int isEofBodyBuf()
{
    return (s_body.curPos < s_body.bodyLen) ? 0 : 1;
}
//try to read length as times pagesize (such as 8KB * N)
static int readBodyBuf(const int needRead)
{
    const int blockSize = 8192;
    char *buff = s_body.bodyBuf + s_body.bodyCurrentLen;
    int nRead;
    int readMore = (needRead + blockSize -1) / blockSize * blockSize;
    int remain = LSAPI_GetReqBodyRemain_r( &g_req );
    //Only when not enough left, needReadChange will be changed!!!
    if (remain < readMore) 
        readMore = remain;

    if ( readMore <= 0 )
        return 0;
    
    nRead = LSAPI_ReadReqBody_r(&g_req, buff, readMore);
    if ( nRead > 0 )
        s_body.bodyCurrentLen += nRead;

    return nRead;
}

static VALUE lsapi_gets( VALUE self )
{
    VALUE str;
    const int blkSize = 4096;
    int n;
    char *p = NULL;
    
#if RUBY_API_VERSION_CODE < 20700
    if (rb_safe_level() >= 4 && !OBJ_TAINTED(self))
    {
        rb_raise(rb_eSecurityError, "Insecure: operation on untainted IO");
    }
#endif
    if (createBodyBuf() == 1)
    {
        return Qnil;
    }   
    
    //comment:
    while((p = memmem(s_body.bodyBuf + s_body.curPos, s_body.bodyCurrentLen - s_body.curPos, "\n", 1)) == NULL) 
    {
        if (isAllBodyRead() == 1)
            break;
        //read one page and check, then reply
        readBodyBuf(blkSize);
    }
    
    p = memmem(s_body.bodyBuf + s_body.curPos, s_body.bodyCurrentLen - s_body.curPos, "\n", 1);
    if (p != NULL)
        n = p - s_body.bodyBuf - s_body.curPos + 1;
    else
        n = s_body.bodyCurrentLen - s_body.curPos;
    
    str = rb_str_buf_new( n );
#if RUBY_API_VERSION_CODE < 20700
    OBJ_TAINT(str);
#endif
    
    if (n > 0)
    {
        rb_str_buf_cat( str, s_body.bodyBuf + s_body.curPos, n );
        s_body.curPos += n;
    }
    
    return str;
}

static VALUE lsapi_read(int argc, VALUE *argv, VALUE self)
{
    VALUE str;
    int n;
    int needRead;
    int nRead;
    
#if RUBY_API_VERSION_CODE < 20700
    if (rb_safe_level() >= 4 && !OBJ_TAINTED(self))
    {
        rb_raise(rb_eSecurityError, "Insecure: operation on untainted IO");
    }
#endif
    if (createBodyBuf() == 1)
    {
        return Qnil;
    }
    
    //we need to consider these 4 cases:
    //1, need all data since argc == 0, we may have all data 2, or not
    //3, need a length of data (argv >= 1), we may have enough data already read, 4, or not
    if (argc == 0)
        n = s_body.bodyLen - s_body.curPos;
    else
    {
        n = NUM2INT(argv[0]); //request that length from currentpos
        if (n < 0)
            return Qnil;
        if (n > s_body.bodyLen - s_body.curPos)
            n = s_body.bodyLen - s_body.curPos;            
    }
    needRead = s_body.curPos + n - s_body.bodyCurrentLen;
    if (needRead < 0)
        needRead = 0;
    
    str = rb_str_buf_new( n );
#if RUBY_API_VERSION_CODE < 20700
    OBJ_TAINT(str);
#endif
    if (n == 0)
        return str;
    
    //copy already have part first
    if (n - needRead != 0)
    {
        rb_str_buf_cat( str, s_body.bodyBuf + s_body.curPos, n - needRead);
        s_body.curPos += (n - needRead);
    }
    
    if (needRead > 0)
    {
        //try to read needRead, but may be less (changed) when read the end of the data
        nRead = readBodyBuf(needRead);
        if (nRead > 0)
        {
            n = ((nRead < needRead) ? nRead : needRead);
            rb_str_buf_cat( str, s_body.bodyBuf + s_body.curPos, n );
            s_body.curPos += n;
        }
    }
    
    return str;
}

static VALUE lsapi_rewind(VALUE self)
{  
    s_body.curPos = 0;
    return self;
}

static VALUE lsapi_each(VALUE self)
{
    VALUE str;
    lsapi_rewind(self);
   
    while(isEofBodyBuf() != 1)
    {
        str = lsapi_gets(self);
        rb_yield(str);
    }
    return self;

}

static VALUE lsapi_eof(VALUE self)
{
    return (LSAPI_GetReqBodyRemain_r( &g_req ) <= 0) ? Qtrue : Qfalse;
}

static VALUE lsapi_binmode(VALUE self)
{
    return self;
}

static VALUE lsapi_isatty(VALUE self)
{
    return Qfalse;
}

static VALUE lsapi_isclosed(VALUE self)
{
    return Qfalse;
}

static VALUE lsapi_sync(VALUE self)
{
    return Qfalse;
}

static VALUE lsapi_setsync(VALUE self,VALUE sync)
{
    return Qfalse;
}

static VALUE lsapi_close(VALUE self)
{
    LSAPI_Flush_r( &g_req );
    if (isBodyWriteToFile())
    {
        //msync(s_body.bodyBuf, s_body.bodyLen, MS_SYNC);
        //sleep(5);
        munmap(s_body.bodyBuf, s_body.bodyLen);
    }
    else
        free(s_body.bodyBuf);
    
    s_body.bodyBuf = NULL;
    s_body.bodyLen = -1;
    s_body.bodyCurrentLen = 0;
    s_body.curPos = 0;    
    //Should the temp be deleted here?!
        
    return Qnil;
}


static VALUE lsapi_reopen( int argc, VALUE *argv, VALUE self)
{
    VALUE orig_verbose;
    if ( self == s_req_stderr )
    {
        /* constant silence hack */
        orig_verbose = (VALUE)ruby_verbose;
        ruby_verbose = Qnil;
        
        rb_define_global_const("STDERR", orig_stderr);
        
        ruby_verbose = (VALUE)orig_verbose;
        
        return rb_funcall2( orig_stderr, rb_intern( "reopen" ), argc, argv );
        
    }
    return self;
}

static void readMaxBodyBufLength()
{
    int n;
    const char *p = getenv( "LSAPI_MAX_BODYBUF_LENGTH" );
    if ( p )
    {
        n = atoi( p );
        if (n > 0)
        {
            if (strstr(p, "M") || strstr(p, "m"))
                MAX_BODYBUF_LENGTH = n * 1024 * 1024;
            else if (strstr(p, "K") || strstr(p, "k"))
                MAX_BODYBUF_LENGTH = n * 1024;
            else
                MAX_BODYBUF_LENGTH = n;
        }
    }
}

static void readTempFileTemplate()
{
    const char *p = getenv( "LSAPI_TEMPFILE" );
    if (p == NULL || strlen(p) > 1024 - 7)
         p = "/tmp/lsapi.XXXXXX";
    
    strcpy(sTempFile, p);
    if (strlen(p) <= 6 || strcmp(p + (strlen(p) - 6), "XXXXXX") != 0)
        strcat(sTempFile, ".XXXXXX");
}

static void initBodyBuf()
{
    s_body.bodyBuf = NULL;
    s_body.bodyLen = -1;
    s_body.bodyCurrentLen = 0;
    s_body.curPos = 0;    
}
void Init_lsapi()
{
    VALUE orig_verbose; 
    char * p;
    int prefork = 0;
    LSAPI_Init();
    initBodyBuf();
    
    readMaxBodyBufLength();
    readTempFileTemplate();
    
    p = getenv("LSAPI_CHILDREN");
    if (p && atoi(p) > 1)
        prefork = 1;

#ifdef rb_thread_select
    LSAPI_Init_Env_Parameters( rb_thread_select );
#else
    LSAPI_Init_Env_Parameters( select );
#endif
    
    s_pid = getpid();
    
    p = getenv( "RACK_ROOT" );
    if ( p )
    {
        if ( chdir( p ) == -1 )
            perror( "chdir()" );
    }
    if ( p || getenv( "RACK_ENV" ) )
        s_fn_add_env = add_env_rails;
    
    orig_stdin = rb_stdin;
    orig_stdout = rb_stdout;
    orig_stderr = rb_stderr;
#if defined( RUBY_VERSION_CODE ) && RUBY_VERSION_CODE < 180
    orig_defout = rb_defout;
#endif
    orig_env = rb_const_get( rb_cObject, rb_intern("ENV") );
    env_copy = rb_funcall( orig_env, rb_intern( "to_hash" ), 0 );
    
    /* tell the garbage collector it is a global variable, do not recycle it. */
    rb_global_variable(&env_copy);
    
    rb_hash_aset( env_copy,rb_tainted_str_new("GATEWAY_Irewindable_input.rbNTERFACE", 17),
                                              rb_tainted_str_new("CGI/1.2", 7));
        
    rb_define_global_function("eval_string_wrap", lsapi_eval_string_wrap, 1);
    
    cLSAPI = rb_define_class("LSAPI", rb_cObject);
    rb_define_singleton_method(cLSAPI, "accept", lsapi_s_accept, 0);
    if (prefork)
    {
        rb_define_singleton_method(cLSAPI, "accept_new_connection", lsapi_s_accept_new_conn, 0);
        rb_define_singleton_method(cLSAPI, "postfork_child", lsapi_s_postfork_child, 0);
        rb_define_singleton_method(cLSAPI, "postfork_parent", lsapi_s_postfork_parent, 0);
    }

    rb_define_method(cLSAPI, "process", lsapi_process, 0 );
    /* rb_define_method(cLSAPI, "initialize", lsapi_initialize, 0); */
    rb_define_method(cLSAPI, "putc", lsapi_putc, 1);
    rb_define_method(cLSAPI, "write", lsapi_write, 1);
    rb_define_method(cLSAPI, "print", lsapi_print, -1);
    rb_define_method(cLSAPI, "printf", lsapi_printf, -1);
    rb_define_method(cLSAPI, "puts", lsapi_puts, -1);
    rb_define_method(cLSAPI, "<<", lsapi_addstr, 1);
    rb_define_method(cLSAPI, "flush", lsapi_flush, 0);
    rb_define_method(cLSAPI, "getc", lsapi_getc, 0);
    /* rb_define_method(cLSAPI, "ungetc", lsapi_ungetc, 1); */
    rb_define_method(cLSAPI, "gets", lsapi_gets, 0);
    
    //TEST: adding readline function to make irb happy?
    /*rb_define_method(cLSAPI, "readline", lsapi_gets, 0); */
    
    rb_define_method(cLSAPI, "read", lsapi_read, -1);
    rb_define_method(cLSAPI, "rewind", lsapi_rewind, 0);
    rb_define_method(cLSAPI, "each", lsapi_each, 0);
    
    rb_define_method(cLSAPI, "eof", lsapi_eof, 0);
    rb_define_method(cLSAPI, "eof?", lsapi_eof, 0);
    rb_define_method(cLSAPI, "close", lsapi_close, 0);
    rb_define_method(cLSAPI, "closed?", lsapi_isclosed, 0);
    rb_define_method(cLSAPI, "binmode", lsapi_binmode, 0);
    rb_define_method(cLSAPI, "isatty", lsapi_isatty, 0);
    rb_define_method(cLSAPI, "tty?", lsapi_isatty, 0);
    rb_define_method(cLSAPI, "sync", lsapi_sync, 0);
    rb_define_method(cLSAPI, "sync=", lsapi_setsync, 1);
    rb_define_method(cLSAPI, "reopen", lsapi_reopen, -1 );
    
    
    s_req = Data_Make_Struct( cLSAPI, lsapi_data, lsapi_mark, free, s_req_data );
    s_req_data->req = &g_req;
    s_req_data->fn_write = LSAPI_Write_r;
    rb_stdin = rb_stdout = s_req;
    
#if defined( RUBY_VERSION_CODE ) && RUBY_VERSION_CODE < 180
    rb_defout = s_req;
#endif

    rb_global_variable(&s_req );
    
    s_req_stderr = Data_Make_Struct( cLSAPI, lsapi_data, lsapi_mark, free, s_stderr_data );
    s_stderr_data->req = &g_req;
    s_stderr_data->fn_write = LSAPI_Write_Stderr_r;
    rb_stderr = s_req_stderr;
    rb_global_variable(&s_req_stderr );
    
    /* constant silence hack */
    orig_verbose = (VALUE)ruby_verbose;
    ruby_verbose = Qnil;
    
    lsapi_env = rb_hash_new();
    clear_env();
    /* redefine ENV using a hash table, should be faster than char **environment */
    rb_define_global_const("ENV", lsapi_env);
    
    rb_define_global_const("STDERR", rb_stderr);
    
    ruby_verbose = (VALUE)orig_verbose;
    
    return;
}

