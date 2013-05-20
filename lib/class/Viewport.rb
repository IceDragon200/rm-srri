#
# rm-srri/lib/class/Viewport.rb
#   by IceDragon
#   dc ??/??/2012
#   dm 29/03/2013
# vr 1.0.1
class SRRI::Viewport

  include SRRI::Interface::IDisposable
  include SRRI::Interface::IZOrder

  def translate(x, y)
    yield x + @rect.x - @ox, y + @rect.y - @oy, @rect.dup
  end

  def initialize(*args)
    case args.size
    when 0
      x, y, w, h = *Graphics.rect.to_a
    when 1
      rect, = *args
      x, y, w, h = *rect.to_a
    when 4
      x, y, w, h = *args
    end
    @rect = Rect.new(x, y, w, h)

    @z = 0
    @ox, @oy = 0, 0

    @visible = true

    @color = Color.new(0, 0, 0, 0)
    @tone  = Tone.new(0, 0, 0, 0)

    setup_iz_id
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
    super(@z)
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
