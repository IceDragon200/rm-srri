#
# rm-srri/lib/interface/iviewport.rb
#   by IceDragon
#   dc ??/??/2012
#   dm 29/03/2013
# vr 1.0.2
module SRRI
module Interface
module IViewport

  include SRRI::Interface::IDrawable
  include SRRI::Interface::IZOrder
  include SRRI::Interface::IDisposable

public

  def viewport=(new_viewport)
    if @_last_viewport != new_viewport
      unregister_drawable
      @viewport = new_viewport ; @_last_viewport = @viewport
      register_drawable
    end
  end

end
end
end
