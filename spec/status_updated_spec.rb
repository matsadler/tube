require 'rubygems'
require 'spec'

$: << File.expand_path(File.dirname(__FILE__) + "/../lib")
require 'tube/status'

describe "Tube::Status#updated" do
  
  before( :all ) do
    @fixture = "fixtures/2009-05-24-18-26-23.html"
  end
  
  it "should have been pulled from the source page" do
    status = Tube::Status.new( @fixture )
    status.updated.class.should == Time
  end
  
  # This test will fail if you're outside of Great Britian, I am yet to work out
  # how to fix that without writing or using a whole bunch of code that needs
  # testing itself.
  it "should be the correct time" do
    status = Tube::Status.new( @fixture )
    status.updated.should == Time.parse( "6:26pm" )
  end
  
  it "should be as BST during British Summer Time" do
    bst_time = Time.parse( "August 1" )
    Time.stub!( :now ).and_return( bst_time )
    
    status = Tube::Status.new( @fixture )
    status.updated.gmt_offset.should == 3600
  end
  
  it "should be as GMT when not British Summer Time" do
    non_bst_time = Time.parse( "January 1" )
    Time.stub!( :now ).and_return( non_bst_time )
    
    status = Tube::Status.new( @fixture )
    status.updated.gmt_offset.should == 0
  end
  
end