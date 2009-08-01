Gem::Specification.new do |s|
  s.name = "tube"
  s.version = "0.1.2"
 
  s.specification_version = 2 if s.respond_to? :specification_version=
 
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mat Sadler"]
  s.date = %q{2009-08-01}
  s.description = %q{A simple Ruby library to access the status of the London Underground network.}
  s.email = %q{mat@sourcetagsandcodes.com}
  s.files = ["lib/line.rb", "lib/status_parser.rb", "lib/line_group.rb", "lib/station.rb", "lib/station_group.rb", "lib/station_group_group.rb", "lib/status.rb", "lib/tube.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/matsadler/tube}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Tube", "--main", "Tube::Status"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.1.1}
  s.summary = %q{A simple Ruby library to access the status of the London Underground network.}
  
  s.add_dependency('hpricot', [">= 0.8.1"])
  s.add_dependency('json', [">= 0"])
end