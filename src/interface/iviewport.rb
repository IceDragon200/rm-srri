#
# src/interface/iviewport.rb
#
module Interface
  module IViewport

    include Interface::IDrawable
    include Interface::IZSortable
    include Interface::IDisposable

private
    def canvas
      return (viewport || Graphics.canvas)
    end

public

    def viewport=(new_viewport)
      if @_last_viewport != new_viewport
        canvas.resort_z # tell the old viewport that it needs refreshing
        unregister_drawable # drop from old viewport
        @viewport = new_viewport
        @_last_viewport = @viewport
        register_drawable # add to new viewport
        canvas.resort_z # tell the new viewport that it needs refreshing
      end
    end

  end
end

