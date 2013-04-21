#
# rm-srri/lib/interface/izorder.rb
#   by IceDragon
#   dc ??/??/2012
#   dm 29/03/2013
# vr 1.0.1
module SRRI
module Interface
module IZOrder

  @@iz_id = 0

private

  def setup_iz_id
    @iz_id = @@iz_id += 1
  end

public

  attr_reader :iz_id

  def z
    0
  end

  def z=(new_z)
    if @_last_z != @z
      Graphics.canvas.reorder_z
      @_last_z = @z
    end
  end

  def viewport
    nil
  end

  def viewport=(new_viewport)
    if @_last_viewport != @viewport
      Graphics.canvas.reorder_z
      @_last_viewport = @viewport
    end
  end

end
end
end
