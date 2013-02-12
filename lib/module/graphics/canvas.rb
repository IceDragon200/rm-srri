module Graphics

  # TODO:
  # Implement Layer system.
  class Canvas

    def do_resort_z
      # Group objects by #z
      # Hash<int z, IDrawable[]>
      zs = @drawable.inject({}) do |r, e|
        src = (e.viewport || e)
        r[[src.z, src.iz_id, e.z, e.iz_id]] = e
        r
      end

      # Jam everything back into the @drawable
      @drawable.clear

      zs.keys.sort.each do
        |key|

        @drawable.push(zs[key])
      end

      @sorted_drawable = true

      return self
    end

    def resort_z
      @sorted_drawable = false
    end

    attr_accessor :drawable, :texture

    def initialize(texture)
      @texture = texture
      @drawable = [] # IDrawable[]
      @opacity = 255
      @clear_color = StarRuby::Color.new(0, 0, 0, 0)
    end

    attr_reader :opacity

    def opacity=(n)
      @opacity = [[n, 0].max, 255].min
    end

    def redraw
      do_resort_z unless @sorted_drawable
      #@texture.clear
      @texture.fill_rect(0, 0, @texture.width, @texture.height, @clear_color)
      #@drawable.each_with_object(@texture, &:draw)
      for obj in @drawable ; obj.draw(@texture) end

      return 0
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

    def add_drawable(idraw_obj)
      @drawable.push(idraw_obj)
      resort_z
      #puts "Added: #{idraw_obj}"
      return self
    end

    def rem_drawable(idraw_obj)
      @drawable.delete(idraw_obj)
      resort_z
      #puts "Removed: #{idraw_obj}"
      return self
    end

    def translate(x, y)
      yield(x, y, rect)
    end

  end

end
