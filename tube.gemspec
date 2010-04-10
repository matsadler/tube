Gem::Specification.new do |s|
  s.name = "tube"
  s.version = "0.2.2"
  s.summary = "Access the status of the London Underground network."
  s.description = "A simple Ruby library to access the status of the London Underground network."
  s.files = Dir["lib/**/*.rb"] + Dir["test/*.*"]
  s.test_files = ["test/status_parser_test.rb"]
  s.require_path = "lib"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
  s.rdoc_options << "--main" << "README.rdoc"
  s.author = "Matthew Sadler"
  s.email = "mat@sourcetagsandcodes.com"
  s.homepage = "http://github.com/matsadler/tube"
  s.add_dependency('nokogiri', [">= 1.4.1"])
end