#
# rm-srri/lib/interface/i_z_order.rb
#   by IceDragon
#   dc ??/??/2012
#   dm 29/03/2013
# vr 1.0.1
module SRRI
  module Interface
    module IZOrder
      @@renderable_id = 0

    private

      def setup_renderable_id
        @renderable_id = @@renderable_id += 1
      end

    public

      attr_reader :renderable_id

      def z
        @z
      end

      def z=(new_z)
        if @z != new_z
          @z = new_z.to_i
          Graphics.canvas.reorder_z
        end
      end

      def viewport
        @viewport
      end

      def viewport=(new_viewport)
        if @_last_viewport != new_viewport
          cycle_register { |_| @_last_viewport = @viewport = new_viewport }
          Graphics.canvas.reorder_z
        end
      end
    end
  end
end
