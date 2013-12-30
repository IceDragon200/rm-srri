#
# rm-srri/lib/module/graphics/Canvas.rb
#   dm 09/05/2013
# vr 1.0.0
module SRRI
  module Graphics

    # TODO:
    #   Implement Layer system.
    class Canvas

      attr_accessor :drawable
      attr_reader :texture
      attr_reader :opacity

      def do_reorder_z
        @drawable.sort_by!(&:render_priority)
        ##
        # IceDragon Zmap Z-sort algorithim
        #zmap = {}
        #@drawable.each do |obj|
        #  (zmap[obj.viewport ? obj.viewport.z : obj.z] ||= []) << obj
        #end
        #@drawable.clear
        #zmap.keys.sort.each do |k|
        #  @drawable.concat(zmap.fetch(k).sort_by { |o| [o.z, o.y, o.iz_id] })
        #end
        @sorted_drawable = true
        return self
      end

      def reorder_z
        @sorted_drawable = false
      end

      def initialize(texture)
        @texture = texture
        @drawable = [] # IRenderable[]
        @opacity = 255
      end

      def texture=(new_texture)
        @texture = new_texture
      end

      def opacity=(n)
        @opacity = [[n, 0].max, 255].min
      end

      def redraw
        do_reorder_z unless @sorted_drawable
        @texture.clear
        for obj in @drawable
          obj.render(@texture)
        end
      end

      def width
        @texture.width
      end

      def height
        @texture.height
      end

      def rect
        if @rect and @rect.width != @texture.width || @rect.height != @texture.height
          @rect = nil
        end
        return @rect ||= Rect.new(0, 0, width, height)
      end

      def add_renderable(idraw_obj)
        @drawable.push(idraw_obj)
        reorder_z
        #puts "Added: #{idraw_obj}"
        return self
      end

      def rem_renderable(idraw_obj)
        @drawable.delete(idraw_obj)
        reorder_z
        #puts "Removed: #{idraw_obj}"
        return self
      end

      def clear
        @drawable.each { |d| d.dispose if d && !d.disposed? rescue nil }
        @drawable.clear
        @texture.clear
        reorder_z
        self
      end

      def translate(x, y)
        yield(x, y, rect)
      end

    end

  end
end
