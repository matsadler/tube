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
    
  end
end