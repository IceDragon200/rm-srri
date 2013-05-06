#
# rm-srri/lib-exp/bitmap-addon.rb
# vr 1.4.0
class SRRI::Bitmap

  def self.bind_from_cairo(cairo_surface)
    return new(StarRuby::Texture.bind_from_cairo(cairo_surface))
  end

  def blend_fill_rect(*args)
    case args.size
    # rect, color
    when 2
      rect, color = *args
      x, y, w, h = rect.to_a
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
  # draw_line(Vector2 v1, Vector2 v2, int weight, Color color)
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
  # noise(Rect rect, Float delta, Boolean Bipolar)
  #
  def noise(delta=0.1, rect=self.rect, bipolar=true, subtractive=false)
    TextureTool.noise(@texture, rect, delta, bipolar, subtractive)
    self
  end

  ##
  # crop(int x, int y, int w, int h)
  # crop(rect)
  def crop(*args)
    case args.size
    # rec
    when 1
      rect, = args
      x, y, w, h = rect.to_a
    # x, y, width, height, color
    when 4
      x, y, w, h = *args
    end
    Bitmap.new(@texture.crop(x, y, w, h))
  end

  def fill(color)
    @texture.fill(color)
    self
  end

end
