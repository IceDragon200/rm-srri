#
# src/interface/izsortable.rb
#
module Interface
  module IZSortable

    @@iz_id = 0

private

    def setup_iz_id
      @iz_id = @@iz_id += 1
    end

public

    def iz_id
      @iz_id
    end

    def z
      0
    end

    def z=(new_z)
      if @_last_z != @z
        Graphics.canvas.resort_z
        @_last_z = @z
      end
    end

    def viewport
      nil
    end

    def viewport=(new_viewport)
      if @_last_viewport != @viewport
        Graphics.canvas.resort_z
        @_last_viewport = @viewport
      end
    end

  end
end
