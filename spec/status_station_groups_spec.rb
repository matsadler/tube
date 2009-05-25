require 'rubygems'
require 'spec'

$: << File.expand_path(File.dirname(__FILE__) + "/../lib")
require 'tube'

# These tests are very tightly bound to the fixture, but that can't be helped,
# the whole point it to make sure the right data is being pulled from it.
# 
describe "Tube::Status#station_groups" do
  
  before( :all ) do
    @status = Tube::Status.get( "fixtures/2009-05-24-18-26-23.html" )
  end
  
  it "should have been pulled from the source page" do
    @status.station_groups.length.should == 2
    @status.station_groups.first.length.should == 4
    @status.station_groups.last.length.should == 16
  end
  
  it "should get all group names in order" do
    group_names = ["Closed stations", "Station maintenance"]
    
    @status.station_groups.map {|group| group.name}.should == group_names
  end
  
  it "should get all station names in order" do
    closed_stations = ["Goodge Street", "Hatton Cross", "Holloway Road",
                                                          "Wood Green Station"]
    under_maintenance = ["Blackfriars", "Camden Town", "East Ham",
                      "Fulham Broadway", "Heathrow Terminals 1-2-3", "Highgate",
      "King's Cross St.Pancras", "Marble Arch", "Monument", "Piccadilly Circus",
                  "Pimlico", "Seven Sisters", "Swiss Cottage", "Tottenham Hale",
                                                "Warren Street", "Westminster"]
    
    @status.station_groups.first.map {|s| s.name}.should == closed_stations
    @status.station_groups.last.map {|s| s.name}.should == under_maintenance
  end
  
  it "should get multiple paragraphs of a message" do
    text_line_1 = /Saturday 23 until Bank Holiday Monday 25 May/
    text_line_2 = /Tottenham Court Road and Warren Street/
    
    @status.station_groups.first[0].message.should =~ text_line_1
    @status.station_groups.first[0].message.should =~ text_line_2
  end
  
  it "should not include link text in a message" do
    text_line_3 = /See how we are transforming the Tube/
    
    @status.station_groups.first[0].message.should_not =~ text_line_3
  end
  
end