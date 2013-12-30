#
# rm-srri/lib-exp/sr-chipmap.rb
#   by IceDragon
#   dc ??/??/2012
#   dm 07/05/2013
# vr 1.2.0
class SRRI::Chipmap

  include SRRI::Interface::IRenderable
  include SRRI::Interface::IZOrder

  register_renderable('Chipmap')

  class ChipmapError < Exception
    #
  end

  LAYER_TILE   = 0
  LAYER_SHADOW = 1
  LAYER_FLASH  = 2

  LAYER_COUNT  = 3

  LAYER_BLEND_TYPE = [:alpha, :alpha, :add]
  LAYER_OPACITY = [255, 128, 255]

  @@flash_cache = {}

  ##
  # render(Texture texture)
  def render(texture)
    return false if @_disposed
    return false unless @map_data || @shadow_data || @flash_data
    return false unless @visible
    return false if @viewport and !@viewport.visible
    return false if @opacity <= 0

    (@viewport || Graphics).translate(@x, @y) do |vx, vy, vrect|
      #dx, dy, dw, dh = SRRI.viewport_clip(vrect, vx, vy, width, height)
      old_clip = texture.clip_rect
      texture.clip_rect = vrect
      for i in 0...LAYER_COUNT
        next unless layer_enabled?(i)
        #puts "drawing layer #{i} #{[ox, oy, x, y, width, height]}"
        layer = @layers[i]
        texture.render_texture(layer, vx, vy,
                               src_x: ox, src_y: oy,
                               src_width: width, src_height: height,
                               alpha: LAYER_OPACITY[i] * @opacity / 255,
                               blend_type: LAYER_BLEND_TYPE[i])
      end
      texture.clip_rect = old_clip
    end
    return true
  end

  attr_accessor :map_data, :shadow_data, :flash_data # Matrix
  attr_accessor :tilesize
  attr_accessor :tile_bitmap
  attr_accessor :tile_columns
  attr_accessor :visible
  attr_reader :viewrect # Rect

  def initialize(viewport=nil)
    @viewport = viewport

    @tilesize = 32
    @tile_columns = 16

    @visible = true

    @opacity = 255
    @viewrect = Rect.new(0, 0, 0, 0)
    @x, @y, @z = 0, 0, 0
    @ox, @oy = 0, 0

    @map_data    = nil
    @shadow_data = nil
    @flash_data  = nil

    @tile_bitmap = nil

    @_disposed = false

    @layers = Array.new(LAYER_COUNT, nil)

    setup_iz_id
    register_renderable
    if block_given?
      yield self
      refresh
      view_all
    end
  end

  def x
    @x
  end

  def y
    @y
  end

  #def z
  #  @z
  #end

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
    @tilesize * data_xsize
  end

  def height_abs
    @tilesize * data_ysize
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

  #def z=(new_z)
  #  super(new_z)
  #end

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
    data = any_data
    data_width  = data.xsize
    data_height = data.ysize
    pxw, pxh = @tilesize * data_width, @tilesize * data_height
    for i in 0...LAYER_COUNT
      @layers[i] = StarRuby::Texture.new(pxw, pxh)
    end
  end

  def dispose_layers
    for layer in @layers
      layer.dispose if layer && !layer.disposed?
    end
  end

  def dispose
    super
    dispose_layers
  end

  def refresh
    assert_data

    dispose_layers
    create_layers

    redraw_layers

    return self
  end

  def update
    # flash table
  end

  def reveal
    @viewrect.set(0, 0,
                  @map_data.xsize * @tilesize, @map_data.ysize * @tilesize)
    self
  end

  def layer_enabled?(i)
    if    i == 0 then !!@map_data
    elsif i == 1 then !!@shadow_data
    elsif i == 2 then !!@flash_data
    else              false
    end
  end

private

  def any_data
    data = @map_data || @shadow_data || @flash_data
  end

  def data_xsize
    return any_data.xsize
  end

  def data_ysize
    return any_data.ysize
  end

  def assert_data
    mdsize = @map_data    ? [@map_data.xsize,    @map_data.ysize]    : nil
    sdsize = @shadow_data ? [@shadow_data.xsize, @shadow_data.ysize] : nil
    fhsize = @flash_data  ? [@flash_data.xsize,  @flash_data.ysize]  : nil
    return false unless mdsize || sdsize || fhsize
    mdsize ||= sdsize || fhsize
    sdsize ||= mdsize || fhsize
    fhsize ||= mdsize || sdsize
    if mdsize != sdsize || sdsize != fhsize || mdsize != fhsize
      raise(ChipmapError,
            "Data size mismatch: Map=%s Shadow=%s Flash=%s" % [mdsize,
                                                               sdsize,
                                                               fhsize])
    end
    return true
  end

  def index_to_xy(index)
    return [(index % @tile_columns), (index / @tile_columns)]
  end

  def tile_rect(x, y)
    return Rect.new(x * @tilesize, y * @tilesize, @tilesize, @tilesize)
  end

  def draw_tile(x, y)
    index = @map_data[x, y]
    return if index < 0
    tx, ty = index_to_xy(index)
    r = tile_rect(x, y)
    tr = tile_rect(tx, ty)
    texture = @layers[LAYER_TILE]
    texture.render_texture(@tile_bitmap.texture, r.x, r.y,
                           src_rect: tr, alpha: 255, blend_type: :alpha)
  end

  def clear_tile(x, y)
    r = tile_rect(x, y)
    texture = @layers[LAYER_TILE]
    texture.clear_rect(r.x, r.y, r.width, r.height)
  end

  def redraw_tile(x, y)
    clear_tile(x, y)
    draw_tile(x, y)
  end

  def draw_tile_layer
    return unless @map_data
    for y in 0...@map_data.ysize
      for x in 0...@map_data.xsize
        draw_tile(x, y)
      end
    end
  end

  ##
  # draw_shadow_layer
  #   BIT[1] - Top Left
  #   BIT[2] - Top Right
  #   BIT[3] - Bottom Left
  #   BIT[4] - Bottom Right
  def draw_shadow_layer
    return unless @shadow_data
    texture = @layers[LAYER_SHADOW]
    shadow_color = Color.new(0, 0, 0, 255)
    shadow_size = @tilesize / 2
    bitmask1 = SRRI::BIT[1]
    bitmask2 = SRRI::BIT[2]
    bitmask3 = SRRI::BIT[3]
    bitmask4 = SRRI::BIT[4]
    for y in 0...@shadow_data.ysize
      for x in 0...@shadow_data.xsize
        byte = @shadow_data[x, y] & 0xF
        tx = x * @tilesize
        ty = y * @tilesize
        # shadow
        if byte & bitmask1 == bitmask1
          texture.fill_rect(tx, ty,
                            shadow_size, shadow_size, shadow_color)
        end
        if byte & bitmask2 == bitmask2
          texture.fill_rect(tx + shadow_size, ty,
                            shadow_size, shadow_size, shadow_color)
        end
        if byte & bitmask3 == bitmask3
          texture.fill_rect(tx, ty + shadow_size,
                            shadow_size, shadow_size, shadow_color)
        end
        if byte & bitmask4 == bitmask4
          texture.fill_rect(tx + shadow_size, ty + shadow_size,
                            shadow_size, shadow_size, shadow_color)
        end
      end
    end
  end

  def draw_flash_layer
    return unless @flash_data
    texture = @layers[LAYER_FLASH]
    for y in 0...@flash_data.ysize
      for x in 0...@flash_data.xsize
        rgb12 = @flash_data[x, y] & 0xFFF
        if rgb12 > 0
          color = SRRI.rgb12_color(rgb12)
          texture.fill_rect(tile_rect(x, y), color)
        end
      end
    end
  end

  def clear_tile_layer
    texture = @layers[LAYER_TILE]
    texture.clear
  end

  def clear_shadow_layer
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