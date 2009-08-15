module Tube # :nodoc:
  
  # Models the status of the London Underground network as displayed on
  # http://www.tfl.gov.uk/tfl/livetravelnews/realtime/tube/default.html.
  # 
  # It is a very thin abstraction over the tfl website, as a result the access
  # to data on stations is somewhat different to lines due to the differing
  # presentation.
  # However it is very dynamic, for example should the East London line return
  # it will show up in the lines array automatically.
  # 
  # ==Example Usage
  #  require 'tube/status'
  #  
  #  status = Tube::Status.new
  #  
  #  broken_lines = status.lines.select {|line| line.problem?}
  #  broken_lines.collect {|line| line.name}
  #  #=> ["Circle", "District", "Jubilee", "Metropolitan", "Northern"]
  #  
  #  status.lines.detect {|line| line.id == "circle"}.message
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
    def initialize( url=
        "http://www.tfl.gov.uk/tfl/livetravelnews/realtime/tube/default.html" )
      @url = url
      
      doc = Hpricot( open( @url ) )
      
      results = Tube::StatusParser.parse( doc )
      
      @updated = results[:updated]
      
      @lines = results[:lines].map do |line|
        id = line[:html_class]
        name = line[:name]
        status_text = line[:status][:headline]
        problem = line[:status][:problem]
        message = line[:status][:message]
        
        Line.new( id, status_text, problem, message, name )
      end
      
      @station_groups = results[:station_groups].inject( {} ) do |memo, group|
        stations = group[:stations].map do |station|
          Station.new( station[:name], station[:message] )
        end
        
        memo[group[:name]] = stations
        memo
      end
      
      self
    end
    
    alias reload initialize
    public :reload
    
  end
end