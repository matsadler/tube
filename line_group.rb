module Tube # :nodoc:
  
  # Really just an array with an appropriate #to_xml method.
  # Require 'rexml/document' if you want to use this method.
  # 
  class LineGroup < Array
    
    # :call-seq: line_group.to_xml -> string
    # line_group.to_xml(false) -> rexml_document.
    # 
    # Returns a string of XML representing the object.
    #  <lines>
    #    contents of the array as xml...
    #  </lines>
    # 
    # Alternately pass false as the only argument to get an instance of
    # REXML::Document.
    # 
    def to_xml( as_string=true )
      doc = REXML::Document.new
      root = doc.add_element( "lines" )
      each do |e|
        root.add_element( e.to_xml( false ) )
      end
      if as_string then doc.to_s else doc end
    end
    
  end
end