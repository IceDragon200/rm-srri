#
# rm-srri/lib-exp/bitmap-addon.rb
# vr 1.4.0
class SRRI::Bitmap

  ##
  # blend_fill_rect(Rect rect, Color color)
  # blend_fill_rect(Integer x, Integer y, Integer width, Integer height,
  #                 Color color)
  def blend_fill_rect(*args)
    case args.size
    # rect, color
    when 2
      rect, color = *args
      x, y, w, h = Rect.cast(rect).to_a
    # x, y, width, height, color
    when 5
      x, y, w, h, color = *args
    else
      raise(ArgumentError, "Expected 2 or 5 but received #{args.size}")
    end
    @texture.render_rect(x, y, w, h, color)
    self
  end

  ##
  # draw_line(Vector2 v1, Vector2 v2, Color color)
  # draw_line(Integer x1, Integer y1, Integer x2, Integer y2, Color color)
  #   Vector2
  #     can be any object which has a #x, and #y property (Float or Integer)
  def draw_line(*args)
    case args.size
    # v1, v2, color
    when 3
      v1, v2, color = *args
      x1, y1 = *v1.to_a
      x2, y2 = *v2.to_a
    # x1, y1, x2, y2, color
    when 5
      x1, y1, x2, y2, color = *args
    end
    @texture.render_line(x1, y1, x2, y2, color)
    self
  end

  ##
  # noise(Rect rect, Float delta, Boolean Bipolar) -> self
  def noise(delta=0.1, rect=self.rect, bipolar=true, subtractive=false)
    TextureTool.noise(@texture, Rect.cast(rect), delta, bipolar, subtractive)
    self
  end

  ##
  # crop(Integer x, Integer y, Integer w, Integer h) |
  # crop(Rect rect)                                  | -> Bitmap
  def crop(*args)
    case args.size
    # rec
    when 1
      rect, = args
      x, y, w, h = Rect.cast(rect).to_a
    # x, y, width, height, color
    when 4
      x, y, w, h = *args
    end
    Bitmap.new(@texture.crop(x, y, w, h))
  end

  ##
  # pallete -> Array<Color>
  def pallete
    check_disposed
    result = []
    for y in 0...@texture.height
      for x in 0...@texture.width
        col_ary = @texture[x, y].to_a
        col_ary.map!(&:to_i)
        result.push(col_ary) unless result.include?(col_ary)
      end
    end

    result.replace(
      result.sort_by do |a|
        a.reverse
      end
    )
    result.collect! do
      |(r, g, b, a)|

      StarRuby::Color.new(r, g, b, a)
    end

    return result
  end

  ##
  # fill(Color color) -> self
  def fill(color)
    @texture.fill(color)
    self
  end

  def self.bind_from_cairo(cairo_surface)
    return new(StarRuby::Texture.bind_from_cairo(cairo_surface))
  end

end
