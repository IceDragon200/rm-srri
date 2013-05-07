#
# rm-srri/lib-exp/sr-chipmap.rb
#   by IceDragon
#   dc ??/??/2012
#   dm 07/05/2013
# vr 1.2.0
class SRRI::Chipmap

  class ChipmapError < StandardError
    #
  end

  include SRRI::Interface::IDrawable
  include SRRI::Interface::IDisposable
  include SRRI::Interface::IZOrder

  LAYER_TILE   = 0x0
  LAYER_SHADOW = 0x1
  LAYER_FLASH  = 0x2

  LAYER_COUNT  = 3

  LAYER_BLEND_TYPE = [:alpha, :alpha, :add]
  LAYER_OPACITY = [nil, 128, 255]

  @@flash_cache = {}

  def draw(texture)
    return false if @_disposed
    return false unless @texture
    return false if @texture.disposed?
    return false unless @visible
    return false if @opacity <= 0

    for i in 0...LAYER_COUNT
      layer = @layers[i]
      texture.render_texture(layer, x, y,
                             src_x: ox, src_y: oy,
                             src_width: width, src_height: height,
                             alpha: LAYER_OPACITY[i] || @opacity,
                             blend_type: LAYER_BLEND_TYPE[i])
    end
  end

  attr_accessor :map_data, :shadow_data, :flash_data # Table<dim: 2>
  attr_accessor :tilesize
  attr_accessor :tile_bitmap
  attr_accessor :tile_columns
  attr_reader :viewrect # Rect

  def initialize
    @tilesize = 32
    @tile_columns = 16

    @visible = true

    @opacity = 255
    @viewrect = Rect.new(0, 0, 0, 0)
    @z = 0
    @ox, @oy = 0, 0

    @map_data    = nil
    @shadow_data = nil
    @flash_data  = nil

    @tile_bitmap = nil

    @_disposed = false

    @layers = Array.new(LAYER_COUNT, nil)

    register_drawable
    setup_iz_id
  end

  def x
    @x
  end

  def y
    @y
  end

  def z
    @z
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

  def opacity
    @opacity
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

  def opacity=(new_opacity)
    @opacity = [[new_opacity.to_i, 0].max, 255].min
  end

  def create_layers
    pxw, pxh = @tilesize * @map_data.xsize, @tilesize * @map_data.ysize
    for i in 0...LAYER_COUNT
      @layers[i] = StarRuby::Texture.new(pxw, pxh)
    end
  end

  def dispose_layers
    for layer in @layers
      layer.dispose unless layer.disposed?
    end
  end

  def dispose
    super
    dispose_texture
  end

  def refresh
    raise(ChipmapError, "map_data has not been set") unless @map_data
    raise(ChipmapError, "tile_bitmap has not been set") unless @tile_bitmap

    dispose_layers
    create_layers
    draw_tile_layer
    draw_shadow_layer
    draw_flash_layer

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

  def draw_tile(x, y)
    tx, ty = index_to_xy(@map_data[x, y])
    r = tile_rect(x, y)
    tr = tile_rect(tx, ty)
    texture = @layers[LAYER_TILE]
    texture.render_texture(@tile_bitmap.texture, r.x, r.y,
                           src_rect: tr, alpha: 255, blend_type: :alpha)
  end

  def clear_tile(x, y)
    r = tile_rect(x, y)
    texture = @layers[LAYER_TILE]
    texture.fill_rect(r.x, r.y, r.width, r.height,
                      StarRuby::Color::COLOR_TRANS)
  end

  def redraw_tile(x, y)
    clear_tile(x, y)
    draw_tile(x, y)
  end

  def draw_tile_layer
    for y in 0...@map_data.ysize
      for x in 0...@map_data.xsize
        draw_tile(x, y)
      end
    end
  end

  def draw_shadow_layer
    return unless @shadow_data
    texture = @layers[LAYER_SHADOW]
    for x in 0...@shadow_data.xsize
      for y in 0...@shadow_data.ysize

      end
    end
  end

  def draw_flash_layer
    return unless @flash_data
    texture = @layers[LAYER_FLASH]
    for x in 0...@flash_data.xsize
      for y in 0...@flash_data.ysize
        rgb12 = @flash_data[x, y] & 0xFFF
        color = SRRI.rgb12_color(rgb12)
        texture.fill_rect(@tilesize * x, @tilesize * y,
                          @tilesize, @tilesize, color)
      end
    end
  end

  def clear_tile_layer
    texture = @layers[LAYER_TILE]
    texture.clear
  end

  def clear_tile_layer
    texture = @layers[LAYER_SHADOW]
    texture.clear
  end

  def clear_flash_layer
    texture = @layers[LAYER_FLASH]
    texture.clear
  end

  def redraw_tile_layer
    clear_tile_layer
    draw_tile_layer
  end

  def redraw_shadow_layer
    clear_shadow_layer
    draw_shadow_layer
  end

  def redraw_flash_layer
    clear_flash_layer
    draw_flash_layer
  end

  def redraw_layers
    redraw_tile_layer
    redraw_shadow_layer
    redraw_flash_layer
  end

end
