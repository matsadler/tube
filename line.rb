module Tube # :nodoc:
  
  # Models the data gathered on a tube line from the tfl.gov.uk "Live travel
  # news" page.
  # 
  # Comes complete with #to_json and #to_xml methods, but these will need 'json'
  # and 'rexml/document' respectively to be loaded to function.
  # 
  class Line
    attr_reader :id
    attr_accessor :status, :problem, :message, :name
    alias_method :problem?, :problem
    
    # :call-seq: Line.new(id, status, problem=false, message=nil, name=nil)
    # 
    # Create a new Line. If name is ommited it will be set to id.
    # 
    def initialize( id, status, problem=false, message=nil, name=nil )
      @id = id
      @status = status
      @problem = problem
      @message = message
      @name = name || @id
    end
    
    # :call-seq: line.to_hash -> hash
    # 
    # Returns a hash representation of the object.
    #  {"id" => "central", "status" => "Good service", "problem" => false,
    #  "message" => nil, "name" => "Central"}
    # 
    # 
    def to_hash
      instance_variables.inject( {} ) do |memo, var|
        memo.merge( {var[1..-1] => instance_variable_get( var )} )
      end
    end
    
    # :call-seq: line.to_json -> string
    # 
    # Returns a string of JSON representing the object.
    #  '{"id":"central", "status":"Good service", "problem":false,
    #  "message":null, "name":"Central"}'
    # 
    def to_json( *args )
      to_hash.to_json( *args )
    end
    
    # :call-seq: line.to_xml -> string
    # line.to_xml(false) -> rexml_document.
    # 
    # Returns a string of XML representing the object.
    #  <line>
    #    <id>central</id>
    #    <status>Good service</status>
    #    <problem>false</problem>
    #    <message/>
    #    <name>Central</name>
    #  </line>
    # 
    # Alternately pass false as the only argument to get an instance of
    # REXML::Document.
    # 
    def to_xml( as_string=true )
      doc = REXML::Document.new
      root = doc.add_element( "line" )
      instance_variables.each do |var|
        el = root.add_element( var[1..-1] )
        el.add_text( instance_variable_get( var ).to_s )
      end
      if as_string then doc.to_s else doc end
    end
    
  end
end