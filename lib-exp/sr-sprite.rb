#
# rm-srri/lib-exp/sr-sprite.rb
# vr 1.0.0
class SRRI::SoftSprite

  include SRRI::Interface::IDrawable
  include SRRI::Interface::IDisposable
  include SRRI::Interface::IZOrder

  def draw(buffer)
    return false if @_disposed
    return false unless @texture
    return false if @texture.disposed?
    return false unless @visible
    return false if @opacity <= 0

    buffer.render_texture(@texture, @x, @y,
                          src_rect: @texture.rect, alpha: @opacity,
                          blend_type: :alpha)
  end

  attr_reader :opacity, :bitmap, :x, :y, :z, :visible

  def initialize(_=nil)
    @bitmap = nil
    @x, @y, @z = 0, 0, 0
    @opacity = 255
    @visible = true

    register_drawable
    setup_iz_id
  end

  def update
  end

  def bitmap=(new_bitmap)
    @bitmap = new_bitmap
    @texture = @bitmap ? @bitmap.texture : nil
  end

  def x=(new_x)
    @x = new_x.to_i
  end

  def y=(new_y)
    @y = new_y.to_i
  end

  def z=(new_z)
    @z = new_z.to_i
    super(@z)
  end

  def width
    return @texture ? @texture.width : 0
  end

  def height
    return @texture ? @texture.height : 0
  end

  def rect
    return Rect.new(@x, @y, width, height)
  end

  def opacity=(new_opacity)
    @opacity = [[0, new_opacity.to_i].max, 255].min
  end

  def visible=(new_visible)
    @visible = !!new_visible
  end

end
