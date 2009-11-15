Gem::Specification.new do |s|
  s.name = "tube"
  s.version = "0.2.0"
  s.summary = "Access the status of the London Underground network."
  s.description = "A simple Ruby library to access the status of the London Underground network."
  s.files = ["lib/tube/line.rb", "lib/tube/station.rb", "lib/tube/status.rb", "lib/tube/status_parser.rb", "test/dummy.html", "test/status_parser_test.rb"]
  s.test_files = ["test/status_parser_test.rb"]
  s.require_path = "lib"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.txt"]
  s.rdoc_options << "--main" << "README.txt"
  s.author = "Matthew Sadler"
  s.email = "mat@sourcetagsandcodes.com"
  s.homepage = "http://github.com/matsadler/tube"
  s.add_dependency('hpricot', [">= 0.8.1"])
end