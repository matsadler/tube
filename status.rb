require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'time'

require 'tube/line'
require 'tube/station'
require 'tube/line_group'
require 'tube/station_group'
require 'tube/station_group_group'

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
  #  status = Tube::Status.get
  #  
  #  broken_lines = status.lines.select {|line| line.problem?}
  #  broken_lines.collect {|line| line.name}
  #  #=> ["Circle", "District", "Jubilee", "Metropolitan", "Northern"]
  #  
  #  status.line(:circle).message
  #  #=> "Saturday 7 and Sunday 8 March, suspended."
  #  
  #  closed_stations = status.station_group(:closed)
  #  closed_stations.collect {|station| station.name}
  #  #=> ["Blackfriars", "Hatton Cross"]
  #  
  #  status.find_station("hatton").message
  #  #=> "Saturday 7 and Sunday 8 March, closed."
  #  
  #  status.updated.strftime("%I:%M%p")
  #  #=> "04:56PM"
  #  
  #  status.reload
  #  status.updated.strftime("%I:%M%p")
  #  #=> "05:00PM"
  # 
  # ==Converting to JSON and XML
  # All objects come complete with #to_json and #to_xml methods. These depend
  # upon the ruby json and REXML libraries, which must be loaded for the methods
  # to function.
  # 
  # ===XML
  #  require 'rexml/document'
  #  
  #  status.line(:central).to_xml
  #  #=> "<line><id>central</id><status>Good service</status>
  #      <problem>false</problem><message/><name>Central</name></line>"
  # 
  # ===JSON
  #  require 'rubygems'
  #  require 'json'
  #  
  #  status.line(:central).to_json
  #  #=> '{"id":"central", "status":"Good service", "problem":false,
  #      "message":null, "name":"Central"}'
  # 
  class Status
    attr_reader :updated, :lines, :station_groups
    
    # :call-seq: Status.get -> status
    # Status.new -> status
    # 
    # Request and parse the status of the London Underground network from the
    # tfl.gov.uk "Live travel news" page.
    # 
    def initialize( url=
        "http://www.tfl.gov.uk/tfl/livetravelnews/realtime/tube/default.html" )
      
      @url = url
      reload
    end
    
    class << self
      alias get new
    end
    
    # :call-seq: status.reload -> status
    # 
    # Re-request the latest status and reload all data.
    # 
    def reload
      doc = Hpricot( open( @url ) )
      
      time = doc.at( "div#service-board" ).previous_sibling.children.first
      @updated = Time.parse( time.inner_text.match( /(\d?\d:\d\d(a|p)m)/ )[0] )
      
      lines = doc.search( "dl#lines dt" ).map do |el|
        id = el.attributes["class"]
        name = el.inner_text.strip
        
        status = el.next_sibling
        if status_el = status.at( "h3" )
          status_text = status_el.inner_text.strip
          message = status.at( "div.message p" ).inner_text.strip
        else
          status_text = status.inner_text.strip
        end
        problem = status.attributes["class"] == "problem"
        
        Line.new( id, status_text, problem, message, name )
      end
      @lines = LineGroup.new( lines )
      
      @station_groups = StationGroupGroup.new
      doc.search( "dl#stations dt" ).each do |el|
        station_group = StationGroup.new( el.inner_text.strip )
        while el = el.next_sibling
          if el.to_html =~ /^<dd/
            name = el.at( "h3" ).inner_text.strip
            message = el.at( "div.message p" ).inner_text.strip
            station = Station.new( name, message )
            station_group.push( station )
          elsif el.to_html =~ /^<dt/
            break
          end
        end
        @station_groups.push( station_group )
      end
      
      self
    end
    
    # :call-seq: status.line(string) -> line or nil
    # status.line(symbol) -> line or nil
    # status.line(regexp) -> line or nil
    # 
    # Get a single Line object. Passing a string will do a fuzzy match on the
    # line id, a symbol will have to match the line id exactly.
    # 
    #  status.line(:hammersmithandcity)   #=>\
    #<Tube::Line:0x1163964 @id="hammersmithandcity", @name="H'smith & City"...
    #  status.line("waterloo")            #=>\
    #<Tube::Line:0x113d700 @id="waterlooandcity", @name="Waterloo & City"...
    #  status.line("east london")         #=>     nil # no longer exists
    # 
    def line( name )
      if name.is_a?( String )
        name = name.gsub( /\s/, "" )
        name.gsub!( /&/, "and" )
        name.gsub!( /'/, ".+" )
        name = Regexp.new( name, true )
      elsif name.is_a?( Symbol )
        name = /^#{name}$/
      end
      @lines.detect {|line| line.id =~ name}
    end
    
    # :call-seq: status.find_station(string) -> station or nil
    # status.find_station(symbol) -> station or nil
    # status.find_station(regexp) -> station or nil
    # 
    # Get a single Station object. See #find_stations for more details. If more
    # than one station is found the one with the shortest name will be returned.
    # 
    def find_station( name )
      results = find_stations( name )
      
      if results.length == 1
        results.first
      else
        results.sort do |a,b|
          a.name.gsub(/\(.+\)/, "").length <=> b.name.gsub(/\(.+\)/, "").length
        end.first
      end
    end
    
    # :call-seq: status.find_stations(string) -> array
    # status.find_stations(symbol) -> array
    # status.find_stations(regexp) -> array
    # status.find_stations(array) -> array
    # status.find_stations -> array
    # 
    # Get all Station objects matching the argument. Passing a string will do a
    # fuzzy match on the station name, a symbol will have to match the station
    # name exactly, an array will return all matches (without duplicates) for
    # the contents of the array.
    # 
    # With no arguments simply returns all stations.
    # 
    #  status.find_stations("acton")     \
    #=> [#<Tube::Station:0x110d7e4 @message="Closed.", @name="East Acton">]
    #  status.find_stations(:Bank)            #=> [] # No problems at Bank
    #  status.find_stations("tower bridge")   #=> [] # No station by that name
    # 
    def find_stations( name=nil )
      stations = @station_groups.flatten
      
      case name
      when String
        # this could be simplified once I'm more confident about the format of
        # station names
        name = name.gsub( /\s/, "\\s*" )
        name.gsub!( /(and|&)/, "(and|&)" )
        name = Regexp.new( name, true )
        stations = stations.select {|station| station.name =~ name}
      when Regexp
        stations = stations.select {|station| station.name =~ name}
      when Symbol
        stations = stations.select {|station| station.name == name.to_s}
      when Array
        stations = name.map {|n| search_stations( n )}.flatten.uniq
      when nil
        stations
      end
    end
    
    # :call-seq: status.station_group(string) -> station_group or nil
    # status.station_group(symbol) -> station_group or nil
    # status.station_group(regexp) -> station_group or nil
    # 
    # Get a single StationGroup object. Both string and symbol are fuzzy
    # matches.
    # 
    # It appears the two groups are "Closed stations" and "Station maintenance"
    # 
    #  status.station_group(:closed)        #=> [stations...]
    #  status.station_group(:maintenance)   #=> [stations...]
    # 
    def station_group( name )
      if name.is_a?( String ) || name.is_a?( Symbol )
        name = Regexp.new( name.to_s, true )
      end
      @station_groups.detect {|group| group.name =~ name}
    end
    
    # :call-seq: status.to_hash -> hash
    # 
    # Returns a hash representation of the object.
    #  {"stations" => {station groups...},
    #  "lines" => [lines...],
    #  "updated" => Fri Feb 13 23:31:30 +0000 2009}
    # 
    def to_hash
      {"updated" => updated,
        "lines" => lines.map {|e| e.to_hash},
        "stations" => station_groups.to_hash}
    end
    
    # :call-seq: status.to_json -> string
    # 
    # Returns a string of JSON representing the object.
    #  '{"stations":{stations...},
    #  "lines":[lines...],
    #  "updated":"Fri Feb 13 23:31:30 +0000 2009"}'
    # 
    def to_json( *args )
      to_hash.to_json( *args )
    end
    
    # :call-seq: status.to_xml -> string
    # status.to_xml(false) -> rexml_document
    # 
    # Returns a string of XML representing the object.
    #  <status>
    #    <updated>Fri Feb 13 23:31:30 +0000 2009</updated>
    #    lines as xml...
    #    station_groups as xml...
    #  </status>
    # 
    # Alternately pass false as the only argument to get an instance of
    # REXML::Document.
    # 
    def to_xml( as_string=true )
      doc = REXML::Document.new
      root = doc.add_element( "status" )
      root.add_element( "updated" ).add_text( updated.to_s )
      root.add_element( lines.to_xml( false ) )
      root.add_element( station_groups.to_xml( false ) )
      if as_string then doc.to_s else doc end
    end
    
  end
end