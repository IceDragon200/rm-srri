#
# rm-srri/lib/interface/idrawable.rb
#   by IceDragon
#   dc ??/??/2012
#   dm 29/03/2013
# vr 1.0.1
module SRRI
module Interface
module IDrawable

private
  def register_drawable
    # Register
    Graphics.canvas.add_drawable(self)
  end

  def unregister_drawable
    # Register
    Graphics.canvas.rem_drawable(self)
  end

public
  def draw(texture)
    return false
  end

end
end
end
