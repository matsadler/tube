require 'rubygems'
require 'spec'

$: << File.expand_path(File.dirname(__FILE__) + "/../lib")
require 'tube'

# These tests are very tightly bound to the fixture, but that can't be helped,
# the whole point it to make sure the right data is being pulled from it.
# 
describe "Tube::Status#lines" do
  
  before( :all ) do
    @status = Tube::Status.new( "fixtures/2009-05-24-18-26-23.html" )
  end
  
  it "should have been pulled from the source page" do
    @status.lines.length.should == 11
  end
  
  it "should get all line names in order" do
    all_line_names = ["Bakerloo", "Central", "Circle", "District",
          "H'smith & City", "Jubilee", "Metropolitan", "Northern", "Piccadilly",
                                                  "Victoria", "Waterloo & City"]
    
    @status.lines.map {|line| line.name}.should == all_line_names
  end
  
  it "should know which lines have a problem" do
    problems = [false, false, false, false, true, true, true, true, true, false,
                                                                          true]
    
    @status.lines.map {|line| line.problem?}.should == problems
  end
  
  it "should get the correct statuses" do
    statuses = ["Good service", "Good service", "Good service", "Good service",
                "Part closure", "Part closure", "Part closure", "Part closure",
                            "Part suspended", "Good service", "Planned closure"]
    
    @status.lines.map {|line| line.status}.should == statuses
  end
  
  it "should get multiple paragraphs of a message" do
    text_line_1 = /suspended between Finchley Central and High Barnet/
    text_line_2 = /Service A: /
    
    @status.lines[7].message.should =~ text_line_1
    @status.lines[7].message.should =~ text_line_2
  end
  
  it "should not include link text in a message" do
    text_line_3 = /See how we are transforming the Tube/
    
    @status.lines[7].message.should_not =~ text_line_3
  end
  
end