#
# rm-srri/lib-exp/sr-chipmap.rb
#   by IceDragon
#   dc ??/??/2012
#   dm 21/04/2013
# vr 1.1.0
class SRRI::Chipmap

  class ChipmapError < StandardError
    #
  end

  include SRRI::Interface::IDrawable
  include SRRI::Interface::IDisposable
  include SRRI::Interface::IZOrder

  def draw(texture)
    return false if @_disposed
    return false unless @texture
    return false if @texture.disposed?
    return false unless @visible
    return false if @opacity <= 0

    texture.render_texture(@texture, x, y,
                           src_x: ox, src_y: oy,
                           src_width: width, src_height: height,
                           alpha: @opacity, blend_type: :alpha)
  end

  attr_accessor :map_data, :tilesize, :tile_bitmap, :tile_columns
  attr_reader :opacity, :viewrect, :z

  def initialize
    @tilesize = 32
    @tile_columns = 16

    @visible = true

    @opacity = 255
    @viewrect = Rect.new(0, 0, 0, 0)
    @z = 0
    @ox, @oy = 0, 0

    @map_data = nil
    @tile_bitmap = nil

    @_disposed = false

    @texture = nil

    register_drawable
    setup_iz_id
  end

  def x
    @x
  end

  def y
    @y
  end

  def ox
    @viewrect.x
  end

  def oy
    @viewrect.y
  end

  def width
    @viewrect.width
  end

  def height
    @viewrect.height
  end

  def width_abs
    @tilesize * @map_data.xsize
  end

  def height_abs
    @tilesize * @map_data.ysize
  end

  def x=(new_x)
    @x = new_x.to_i
  end

  def y=(new_y)
    @y = new_y.to_i
  end

  def z=(new_z)
    @z = new_z.to_i
  end

  def ox=(n)
    @viewrect.x = n
  end

  def oy=(n)
    @viewrect.y = n
  end

  def width=(n)
    @viewrect.width = n
  end

  def height=(n)
    @viewrect.height = n
  end

  def dispose_texture
    if @texture
      @texture.dispose
      @texture = nil
    end
  end

  def dispose
    super
    dispose_texture
  end

  def opacity=(new_opacity)
    @opacity = [[new_opacity.to_i, 0].max, 255].min
  end

  def refresh
    raise(ChipmapError, "map_data has not been set") unless @map_data
    raise(ChipmapError, "tile_bitmap has not been set") unless @tile_bitmap

    pxw, pxh = @tilesize * @map_data.xsize, @tilesize * @map_data.ysize
    dispose_texture
    @texture = StarRuby::Texture.new(pxw, pxh)
    @texture.clear

    for y in 0...@map_data.ysize
      for x in 0...@map_data.xsize
        draw_tile(x, y)
      end
    end

    return self
  end

  def update
    # flash table
  end

  def view_all
    @viewrect.set(0, 0,
                  @map_data.xsize * @tilesize, @map_data.ysize * @tilesize)
    self
  end

private

  def index_to_xy(index)
    return [(index % @tile_columns), (index / @tile_columns)]
  end

  def tile_rect(x, y)
    return Rect.new(x * @tilesize, y * @tilesize, @tilesize, @tilesize)
  end

  def clear_tile(x, y)
    r = tile_rect(x, y)
    @texture.fill_rect(r.x, r.y, r.width, r.height,
                       StarRuby::Color::COLOR_TRANS)
  end

  def draw_tile(x, y)
    tx, ty = index_to_xy(@map_data[x, y])
    r = tile_rect(x, y)
    tr = tile_rect(tx, ty)
    @texture.render_texture(@tile_bitmap.texture, r.x, r.y,
                            src_rect: tr, alpha: 255, blend_type: :alpha)
  end

  def redraw_tile(x, y)
    clear_tile(x, y)
    draw_tile(x, y)
  end

end
