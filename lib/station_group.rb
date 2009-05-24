module Tube # :nodoc:
  
  # Really just an array that can have a name, plus appropriate #to_json and
  # #to_xml methods.
  # 
  class StationGroup < Array
    attr_reader :name
    
    # :call-seq: StationGroup.new(name, size=0, obj=nil)
    # StationGroup.new(name, array)
    # StationGroup.new(name, size) {|index| block }
    # 
    # See Array.new.
    # 
    def initialize( name, *args )
      @name = name
      super( *args )
    end
    
    # :call-seq: station_group.to_hash -> hash
    # 
    # Returns a hash representation of the object. Also calls #to_hash on its
    # contents.
    #  {"Closed stations" => [array contents...]}
    # 
    def to_hash
      {@name => to_a.map {|e| e.to_hash}}
    end
    
    # :call-seq: station_group.to_json -> string
    # 
    # Returns a string of JSON representing the object.
    #  '{"Closed stations":[array contents...]}'
    # 
    def to_json( *args )
      to_hash.to_json( *args )
    end
    
    # :call-seq: station_group.to_xml -> string
    # station_group.to_xml(false) -> rexml_document.
    # 
    # Returns a string of XML representing the object.
    #  <station_group>
    #    <name>Closed stations</name>
    #    <stations>
    #      contents of the array as xml...
    #    </stations>
    #  </station_group>
    # 
    # Alternately pass false as the only argument to get an instance of
    # REXML::Document.
    # 
    def to_xml( as_string=true )
      doc = REXML::Document.new
      root = doc.add_element( "station_group" )
      root.add_element( "name" ).add_text( name )
      stations = root.add_element( "stations" )
      each do |e|
        stations.add_element( e.to_xml( false ) )
      end
      if as_string then doc.to_s else doc end
    end
    
  end
end