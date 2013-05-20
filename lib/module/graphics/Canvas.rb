#
# rm-srri/lib/module/graphics/Canvas.rb
#   dm 09/05/2013
# vr 1.0.0
module SRRI
module Graphics

  # TODO:
  #   Implement Layer system.
  class Canvas

    attr_accessor :drawable, :texture
    attr_reader :opacity

    def do_reorder_z
      @drawable.map! do |e|
        (v = e.viewport) ? [v.z, v.iz_id, e.z, e.iz_id, e] :
                           [e.z, e.iz_id, 0, 0, e]
      end
      @drawable.sort!
      @drawable.map!(&:last)
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
      @clear_color = StarRuby::Color.new(0, 0, 0, 0)
    end

    def opacity=(n)
      @opacity = [[n, 0].max, 255].min
    end

    def redraw
      do_reorder_z unless @sorted_drawable
      @texture.clear
      #@texture.fill_rect(0, 0, @texture.width, @texture.height, @clear_color)
      #@drawable.each_with_object(@texture, &:draw)
      for obj in @drawable ; obj.render(@texture) end
      return false
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
      @drawable.each(&:dispose)
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
