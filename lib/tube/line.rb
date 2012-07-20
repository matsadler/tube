module Tube # :nodoc:
  
  # Models the data gathered on a tube line from the tfl.gov.uk "Live travel
  # news" page.
  # 
  class Line
    attr_reader :id
    attr_accessor :name, :status, :problem, :message
    alias problem? problem
    
    # :call-seq: Line.new(id, name, status, problem, message=nil)
    # 
    # Create a new Line.
    # 
    def initialize(id, name, status, problem, message=nil)
      @id = id
      @name = name
      @status = status
      @problem = problem
      @message = message
    end
    
  end
end
