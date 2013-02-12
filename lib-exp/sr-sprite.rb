#
# src/sr-sprite.rb
# vr 0.10
class RGX::SrSprite

  include Interface::IDrawable
  include Interface::IDisposable
  include Interface::IZSortable

  def draw(texture)
    return false if @disposed
    return false unless @texture
    return false if @texture.disposed?
    return false unless @visible
    return false if @opacity <= 0

    TextureTool.render_texture_fast(
      texture, @x, @y,
      @texture,
      0, 0, @texture.width, @texture.height,
      @opacity, 1
    )
  end

  attr_reader :opacity, :bitmap, :x, :y, :z, :visible

  def initialize(viewport)
    @bitmap = nil
    @x, @y, @z = 0, 0, 0
    @opacity = 255
    @visible = true

    register_drawable
    setup_iz_id
  end

  def dispose
    @disposed = true
    unregister_drawable
  end

  def disposed?
    return !!@disposed
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
