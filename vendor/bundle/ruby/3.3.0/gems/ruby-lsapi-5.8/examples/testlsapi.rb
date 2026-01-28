#!/usr/local/bin/ruby

require 'lsapi'

$count = 0;

while LSAPI.accept != nil
	print "HTTP/1.0 200 OK\r\nContent-type: text/html\r\n\r\nHello World! \##{$count}<br>\r\n"
	ENV.each_pair {|key, value| print "#{key} is #{value}<br>\r\n" }
	$count = $count + 1
end
