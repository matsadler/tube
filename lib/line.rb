module Tube # :nodoc:
  
  # Models the data gathered on a tube line from the tfl.gov.uk "Live travel
  # news" page.
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
    
  end
end