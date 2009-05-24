module Tube # :nodoc:
  
  # Really just an array with appropriate #to_json and #to_xml methods.
  # 
  class StationGroupGroup < Array
    
    # :call-seq: station_group_group.to_hash -> hash
    # 
    # Returns a hash representation of the object.
    # Calls #to_hash on its contents (which should be station groups) and then
    # merges those hashes. The end results should look something like:
    #  {"Closed stations" => [station group contents...],
    #  "Station maintenance" => [station group contents...]}
    # 
    def to_hash
      inject( {} ) do |memo, e|
        memo.merge( e.to_hash )
      end
    end
    
    # :call-seq: station_group_group.to_json -> string
    # 
    # Returns a string of JSON representing the object.
    #  '{"Closed stations": [station group contents...],
    #  "Station maintenance": [station group contents...]}'
    # 
    def to_json( *args )
      to_hash.to_json( *args )
    end
    
    # :call-seq: station_group_group.to_xml -> string
    # station_group_group.to_xml(false) -> rexml_document.
    # 
    # Returns a string of XML representing the object.
    #  <station_groups>
    #    <station_group>
    #      <name>Closed stations</name>
    #      <stations>
    #        contents of the station group as xml...
    #      </stations>
    #    </station_group>
    #    <station_group>
    #      <name>Station maintenance</name>
    #      <stations>
    #        contents of the station group as xml...
    #      </stations>
    #    </station_group>
    #  </station_groups>
    # 
    # Alternately pass false as the only argument to get an instance of
    # REXML::Document.
    # 
    def to_xml( as_string=true )
      doc = REXML::Document.new
      root = doc.add_element( "station_groups" )
      each do |e|
        root.add_element( e.to_xml( false ) )
      end
      if as_string then doc.to_s else doc end
    end
  end
end