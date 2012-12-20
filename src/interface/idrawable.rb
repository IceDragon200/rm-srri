#
# src/interface/idrawable.rb
#
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
