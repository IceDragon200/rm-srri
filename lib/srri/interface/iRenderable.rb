#
# rm-srri/lib/interface/iRenderable.rb
#   by IceDragon
#   dc ??/??/2012
#   dm 29/03/2013
# vr 1.1.0
module SRRI
  module Interface
    module IRenderable

      RENDERABLE = {}

      include SRRI::Interface::IDisposable

      module IRenderableExtension

        def register_renderable(symbol=self.name)
          IRenderable::RENDERABLE[symbol] = self
        end

      end

      def self.included(mod)
        mod.extend(IRenderableExtension)
      end

    private

      def register_renderable
        # Register
        Graphics.canvas.add_renderable(self)
      end

      def unregister_renderable
        # Register
        Graphics.canvas.rem_renderable(self)
      end

      def cycle_register
        unregister_renderable
        yield self
        register_renderable
      end

    public

      def render(texture)
        return false
      end

      def dispose
        unregister_renderable
        super
      end

      def render_priority
        (v = viewport) ? [v.z, v.rect.y, v.iz_id, z, y, iz_id] :
                         [z,          y,   iz_id, 0, 0,     0]
      end

    end
  end
end
