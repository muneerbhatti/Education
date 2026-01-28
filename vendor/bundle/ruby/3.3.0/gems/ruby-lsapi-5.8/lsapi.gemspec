Gem::Specification.new do |s|
  s.name = %q{ruby-lsapi}
  s.version = "5.8"
  s.date = %q{2025-07-08}
  s.description = "This is a ruby extension for fast communication with LiteSpeed Web Server."
  s.summary = %q{A ruby extension for fast communication with LiteSpeed Web Server.}
  s.authors = ["LiteSpeed Technologies Inc."]
  s.email = "info@litespeedtech.com"
  s.homepage = "http://www.litespeedtech.com/"
  s.files = ["lsapi.gemspec", "README", "examples", "examples/testlsapi.rb", "examples/lsapi_with_cgi.rb", "ext", "ext/lsapi", "ext/lsapi/extconf.rb", "ext/lsapi/lsapidef.h", "ext/lsapi/lsapilib.c", "ext/lsapi/lsapilib.h", "ext/lsapi/lsruby.c", "rails", "rails/dispatch.lsapi", "scripts", "scripts/lsruby_runner.rb", "setup.rb"]
  s.extra_rdoc_files = ["README"]
  s.extensions << "ext/lsapi/extconf.rb"
  s.require_paths << "lib"
end
