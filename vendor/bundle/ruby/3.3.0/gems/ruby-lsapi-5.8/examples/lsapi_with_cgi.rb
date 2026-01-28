#!/usr/local/bin/ruby

require 'lsapi'
require 'cgi'


while LSAPI.accept != nil
    cgi = CGI.new
    name = cgi['name']
    puts cgi.header
    puts "Hello #{name}! <br> " if name
    puts "You are from #{cgi.remote_addr}<br>"

end
