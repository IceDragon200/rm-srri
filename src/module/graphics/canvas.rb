module Graphics

  class Canvas

    ##
    # resort_sprite_z3(IDrawable[] array)
    #
    # Full Resort
    def self.resort_z(array)
      # Hash<int z, IDrawable[]>
      zs = {}

      # Group objects by #z
      array.each do |e|
        z = (e.viewport || e).z
        (zs[z] ||= []).push(e)
      end

      # Sort each value by elements z
      zs.values.each do |ary|
        ary.sort_by do |a| [a.iz_id, a.z] end
      end

      result = []

      # Jam everything back into 1 array
      zs.keys.sort.each do |key|
        result.concat(zs[key])
      end

      return result
    end

    def do_resort_z
      @drawable.replace(Graphics::Canvas.resort_z(@drawable))
      #puts "Currently Drawable: #{@drawable.size}"
      @sorted_drawable = true
    end

    def resort_z
      @sorted_drawable = false
    end

    attr_accessor :drawable, :texture

    def initialize(texture)
      @texture = texture
      @drawable = [] # IDrawable[]
      @opacity = 255
    end

    attr_reader :opacity

    def opacity=(n)
      @opacity = [[n, 0].max, 255].min
    end

    def redraw
      do_resort_z unless @sorted_drawable
      @texture.clear
      @drawable.each do |obj|
        obj.draw(@texture)
      end
      #@texture
      return self
    end

    def width
      @texture.width
    end

    def height
      @texture.height
    end

    def rect
      Rect.new(0, 0, width, height)
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
      yield x + 0, y + 0, rect
    end

  end

end
