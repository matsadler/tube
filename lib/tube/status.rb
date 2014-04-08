require File.expand_path("../tfl_client", __FILE__)
require File.expand_path("../line", __FILE__)
require File.expand_path("../station", __FILE__)

module Tube # :nodoc:
  
  # Models the status of the London Underground network as returned by
  # http://api.tfl.gov.uk.
  # 
  # Before TFL made an API available this library scraped the TFL website, due
  # to this the API provided doesn't (currently) match the TFL API very well.
  # 
  # ==Example Usage
  #  require "tube/status"
  #  
  #  status = Tube::Status.new
  #  
  #  broken_lines = status.lines.select {|line| line.problem?}
  #  broken_lines.collect {|line| line.name}
  #  #=> ["Circle", "District", "Jubilee", "Metropolitan", "Northern"]
  #  
  #  status.lines.detect {|line| line.id == :circle}.message
  #  #=> "Saturday 7 and Sunday 8 March, suspended."
  #  
  #  closed_stations = status.station_groups["Closed stations"]
  #  closed_stations.collect {|station| station.name}
  #  #=> ["Blackfriars", "Hatton Cross"]
  #  
  #  stations = status.station_groups.values.flatten
  #  stations.detect {|station| station.name =~ "hatton"}.message
  #  #=> "Saturday 7 and Sunday 8 March, closed."
  #  
  #  status.updated.strftime("%I:%M%p")
  #  #=> "04:56PM"
  #  
  #  status.reload
  #  status.updated.strftime("%I:%M%p")
  #  #=> "05:00PM"
  # 
  class Status
    attr_reader :updated, :lines, :station_groups
    
    # :call-seq: Status.new -> status
    # 
    # Request and parse the status of the London Underground network from the
    # tfl.gov.uk "Live travel news" page.
    # 
    def initialize(app_id=nil, app_key=nil, host="api.tfl.gov.uk", port=80)
      client = TFLClient.new(app_id, app_key, host, port)
      line_details = client.line_mode_status(modes: %W{tube dlr overground})
      station_details = client.stop_point_mode_disruption(modes: %W{tube dlr overground})
      
      @updated = Time.now
      
      @lines = line_details.map do |line|
        id = line["id"].to_sym
        name = line["name"]
        status_details = line["lineStatuses"].first
        status = status_details["statusSeverityDescription"]
        problem = status_details["statusSeverity"] > 10
        message = status_details["reason"]
        
        Line.new(id, name, status, problem, message)
      end
      
      @station_groups = {}
      station_details.each do |detail|
        station = Station.new(detail["commonName"], detail["description"])
        (@station_groups[detail["type"]] ||= []).push(station)
      end
      
      self
    end
    
    alias reload initialize
    public :reload
    
  end
end