#!/usr/local/bin/ruby

require 'lsapi'

class CodeCache
    def [](filename)
		mtime = File.mtime( filename )		
		
		entry = @cache[filename];
		if entry != nil 
			return entry
						
		end
		code = compile(filename)
		#entry = CodeEntry.new( filename, mtime, code )
		@cache[filename] = code
		return code
    end

    private

    def initialize
      @cache = {}
    end

    def compile(filename)
		open(filename) do |f|
			s = f.read
			s.untaint
			binding = eval_string_wrap("binding")
			return eval(format("Proc.new {\n%s\n}", s), binding, filename, 0)
		end
    end
end


$count = 0;

$cache = CodeCache.new


while true
	$req = LSAPI.accept 
	break if $req == nil 
	
	filename = ENV['SCRIPT_FILENAME']
	filename.untaint

	filename =~ %r{^(\/.*?)\/*([^\/]+)$}
	path   = $1
	Dir.chdir( path )
	#load( filename, true )	
    code = $cache[filename]
    code.call
	
end

class CodeEntry
	public :path, :name, :mtime, :opcode 
	
	def initizlize( filename, mtime, opcode )
		filename =~ %r{^(\/.*?)\/*([^\/]+)$}
		@path   = $1
		@name   = $2
		@mtime  = mtime
		@opcode = opcode
	end

end


