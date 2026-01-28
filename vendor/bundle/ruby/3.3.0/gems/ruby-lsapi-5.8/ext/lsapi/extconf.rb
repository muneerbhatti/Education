require 'mkmf'
dir_config( 'lsapi' )
if ( have_library( "socket" ))
    have_library( "nsl" )
end
if RUBY_VERSION =~ /1.8/ then
    $CPPFLAGS += " -DRUBY_18"
end
if RUBY_VERSION =~ /1.9/ then
    $CPPFLAGS += " -DRUBY_19"
end 
if RUBY_VERSION =~ /2/ then
    $CPPFLAGS += " -DRUBY_2"
end 
create_makefile( "lsapi" )
