require 'rubygems'
require 'spec'

$: << File.expand_path(File.dirname(__FILE__) + "/../lib")
require 'tube'

# These tests are very tightly bound to the fixture, but that can't be helped.
# 
describe "Tube::Status find methods" do
  
  before( :all ) do
    @status = Tube::Status.get( "fixtures/2009-05-24-18-26-23.html" )
  end
  
  describe "#line" do
    it "should be case insensitive with a string" do
      @status.line( "WaterlooAndCity" ).id.should == "waterlooandcity"
    end
    
    it "should cope with spaces with a string" do
      @status.line( "Waterloo and City" ).id.should == "waterlooandcity"
    end
    
    it "should cope with ampersands with a string" do
      @status.line( "Waterloo & City" ).id.should == "waterlooandcity"
    end
    
    it "should cope with abbreviations with a string" do
      @status.line( "H'Smith and City" ).id.should == "hammersmithandcity"
    end
    
    it "should require an exact match with a symbol" do
      @status.line( :hammersmithandcity ).id.should == "hammersmithandcity"
      @status.line( :"H'Smith and City" ).should == nil
    end
    
    it "should return nil on no match" do
      @status.line( :eastlondon ).should == nil
    end
  end
  
  describe "#find_station" do
    it "should be case insensitive with a string" do
      @status.find_station( "camden town" ).name.should == "Camden Town"
    end
    
    it "should do a fuzzy match with a string" do
      @status.find_station( "camden" ).name.should == "Camden Town"
    end
    
    it "should require an exact match with a symbol" do
      @status.find_station( :"Tottenham Hale" ).name.should == "Tottenham Hale"
      @status.find_station( :"Tottenham" ).should == nil
    end
    
    it "should accept a regex" do
      @status.find_station( /swis{2}\scot+age/i ).name.should == "Swiss Cottage"
    end
    
    it "should return the shortest name when multiple matches" do
      # will also be matching "King's Cross St.Pancras"
      @status.find_station( /cross/i ).name.should == "Hatton Cross"
    end
    
    it "should return nil on no match" do
      @status.find_station( :nowhere ).should == nil
    end
  end
  
  describe "#find_stations" do
    it "should be case insensitive with a string" do
      @status.find_stations( "camden town" ).first.name.should == "Camden Town"
    end
    
    it "should do a fuzzy match with a string" do
      @status.find_stations( "camden" ).first.name.should == "Camden Town"
    end
    
    it "should require an exact match with a symbol" do
      @status.find_stations( :"Tottenham Hale" ).first.name.should ==
                                                                "Tottenham Hale"
      @status.find_stations( :"Tottenham" ).first.should == nil
    end
    
    it "should accept a regex" do
      @status.find_stations( /swis{2}\scot+age/i ).first.name.should ==
                                                                "Swiss Cottage"
    end
    
    it "should return multiple matches" do
      @status.find_stations( /cross/i ).map {|s| s.name}.should ==
                                    ["Hatton Cross", "King's Cross St.Pancras"]
    end
    
    it "should accept an array" do
      array = [/swis{2}\scot+age/i, "camden", :Tottenham, /cross/i]
      result_names = ["Swiss Cottage", "Camden Town", "Hatton Cross",
                                                      "King's Cross St.Pancras"]
      
      @status.find_stations( array ).map {|s| s.name}.should == result_names
    end
    
    it "should return empty array on no match" do
      @status.find_stations( :nowhere ).should == []
    end
  end
  
  describe "#station_group" do
    it "should do a fuzzy match with a symbol" do
      @status.station_group( :closed ).name.should == "Closed stations"
    end
    
    it "should do a fuzzy match with a string" do
      @status.station_group("maintenance").name.should == "Station maintenance"
    end
    
    it "should return nil on no match" do
      @status.station_group( :fakegroup ).should == nil
    end
  end
  
end