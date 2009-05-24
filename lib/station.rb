module Tube # :nodoc:
  
  # Models the data gathered on a tube station from the tfl.gov.uk "Live travel
  # news" page.
  # 
  class Station
    attr_reader :name
    attr_accessor :message
    
    # :call-seq: Station.new(name, message=nil)
    # 
    # Create a new Station.
    # 
    def initialize( name, message=nil )
      @name = name
      @message = message
    end
    
    # :call-seq: station.to_hash -> hash
    # 
    # Returns a hash representation of the object.
    #  {"name" => "Bank", "message" => "Undergoing escalator refurbishment."}
    # 
    def to_hash
      instance_variables.inject( {} ) do |memo, var|
        memo.merge( {var[1..-1] => instance_variable_get( var )} )
      end
    end
    
    # :call-seq: station.to_json -> string
    # 
    # Returns a string of JSON representing the object.
    #  '{"name":"Bank", "message":"Undergoing escalator refurbishment."}'
    # 
    def to_json( *args )
      to_hash.to_json( *args )
    end
    
    # :call-seq: station.to_xml -> string
    # station.to_xml(false) -> rexml_document.
    # 
    # Returns a string of XML representing the object.
    #  <station>
    #    <name>Bank</name>
    #    <message>Undergoing escalator refurbishment.</message>
    #  </station>
    # 
    # Alternately pass false as the only argument to get an instance of
    # REXML::Document.
    # 
    def to_xml( as_string=true )
      doc = REXML::Document.new
      root = doc.add_element( "station" )
      instance_variables.each do |var|
        root.add_element( var[1..-1] ).add_text( instance_variable_get( var ) )
      end
      if as_string then doc.to_s else doc end
    end
    
  end
end