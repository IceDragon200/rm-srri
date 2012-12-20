module Graphics

  class FrameTracker

    attr_accessor :count 

    def initialize
      reset
    end

    def reset
      @count = 0
    end

    def update
      @count += 1
    end

  end

end  
