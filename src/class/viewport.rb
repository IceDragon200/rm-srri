class RGX::Viewport

  include Interface::IDisposable

  def translate(sx, sy)
    yield sx + @rect.x - @ox, sy + @rect.y - @oy, @rect.dup
  end

  def initialize(*args)
    case args.size
    when 0
      x, y, w, h = *Graphics.rect.as_ary
    when 1
      rect, = *args
      x, y, w, h = *rect.as_ary
    when 4
      x, y, w, h = *args
    end
    @rect = Rect.new(x, y, w, h)

    @z = 0
    @ox, @oy = 0, 0

    @visible = true

    @color = Color.new(0, 0, 0, 0)
    @tone  = Tone.new(0, 0, 0, 0)
  end

  def flash(color, duration)
  end

  def update
  end

  attr_reader :rect,
              :ox, :oy, :z,
              :visible,
              :tone, :color

  def z=(new_z)
    @z = new_z.to_i
  end

  def ox=(new_ox)
    @ox = new_ox.to_i
  end

  def oy=(new_oy)
    @oy = new_oy.to_i
  end

  def rect=(new_rect)
    @rect = new_rect
  end

  def visible=(new_visible)
    @visible = !!new_visible
  end

  def color=(new_color)
    @color = new_color
  end

  def tone=(new_tone)
    @tone = new_tone
  end

end
