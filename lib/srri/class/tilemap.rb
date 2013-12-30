#
# rm-srri/lib/class/Tilemap.rb
#   by Fomar0153
#      IceDragon
#
# Fomar0153's Tilemap
#   This is a RGSS3 Tilemap implementation done by Fomar0153 and IceDragon
#   Fomar0153 did all the tile rendering code, IceDragon handled the
#   flash and shadow layers
class SRRI::Tilemap

  include SRRI::Interface::IRenderable
  include SRRI::Interface::IZOrder

  #register_renderable('Tilemap')

  #--------------------------------------------------------------------------
  # * Constants
  #--------------------------------------------------------------------------
  TILESIZE = 32
  #--------------------------------------------------------------------------
  # * Class Variables
  #--------------------------------------------------------------------------
  @@flash_cache = {}
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :bitmaps
  attr_reader   :map_data
  attr_reader   :flash_data
  attr_accessor :flags
  attr_reader   :viewport
  attr_accessor :visible
  attr_reader   :ox
  attr_reader   :oy
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    @bitmaps = []
    @visible = true
    @ox = 0
    @oy = 0
    @animated_layer = []
    @layers = Array.new(5) { Sprite.new }
    @anim_count = 0
    @_disposed = false
    @layers[0].z = 0
    @layers[1].z = 100
    @layers[2].z = 200
    @layers[3].z = 201        # Shadow Layer
    @layers[4].z = 202        # Flash Layer (More like static Color)
    @layers[4].blend_type = 1 # add blend

    #register_renderable
    setup_iz_id

    self.viewport = viewport
  end
  def x
    0
  end
  def y
    0
  end
  def z
    0
  end
  #--------------------------------------------------------------------------
  # * Viewport Assign
  #--------------------------------------------------------------------------
  def viewport=(new_viewport)
    super(new_viewport)
    for layer in @layers
      layer.viewport = @viewport
    end
  end

  #--------------------------------------------------------------------------
  # * Free
  #--------------------------------------------------------------------------
  def dispose
    super
    for layer in @layers
      layer.bitmap.dispose if layer.bitmap && !layer.bitmap.disposed?
      layer.dispose
    end
    for layer in @animated_layer
      layer.dispose unless layer.disposed?
    end
  end

  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    @anim_count = (@anim_count + 1) % [(@animated_layer.size * 30), 1].max
    @layers[0].bitmap = @animated_layer[@anim_count/30]
    #@layers[4].opacity = 0x80 + 0x7F * @anim_count / 30.0
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    return if @map_data.nil? || @flags.nil?
    for layer in @layers
      layer.bitmap.dispose if layer.bitmap && !layer.bitmap.disposed?
      layer.bitmap = nil
    end
    draw_animated_layer
    draw_upper_layers
    draw_shadow_layer
    refresh_flash_data
  end
  #--------------------------------------------------------------------------
  # * Refresh Flash Data
  #--------------------------------------------------------------------------
  def refresh_flash_data
    @layers[4].bitmap.dispose if @layers[4].bitmap && !@layers[4].bitmap.disposed?
    draw_flash_layer
  end
  #--------------------------------------------------------------------------
  # * Draw Animated Layer
  #--------------------------------------------------------------------------
  def draw_animated_layer
    bitmap = Bitmap.new(@map_data.xsize * TILESIZE, @map_data.ysize * TILESIZE)
    if need_animated_layer?
      @animated_layer = [bitmap, bitmap.dup, bitmap.dup]
    else
      @animated_layer = [bitmap]
    end
    @layers[0].bitmap = @animated_layer[0]
    for x in 0...@map_data.xsize
      for y in 0...@map_data.ysize
        draw_a1_tile(x,y,@map_data[x,y,0],true) if @map_data[x,y,0].between?(2048,2815)
        draw_a2_tile(x,y,@map_data[x,y,0]) if @map_data[x,y,0].between?(2816,4351)
        draw_a3_tile(x,y,@map_data[x,y,0]) if @map_data[x,y,0].between?(4352,5887)
        draw_a4_tile(x,y,@map_data[x,y,0]) if @map_data[x,y,0].between?(5888,8191)
        draw_a5_tile(x,y,@map_data[x,y,0]) if @map_data[x,y,0].between?(1536,1663)
      end
    end
    for x in 0...@map_data.xsize
      for y in 0...@map_data.ysize
        draw_a1_tile(x,y,@map_data[x,y,1],true) if @map_data[x,y,1].between?(2048,2815)
        draw_a2_tile(x,y,@map_data[x,y,1]) if @map_data[x,y,1].between?(2816,4351)
      end
    end
  end

  #--------------------------------------------------------------------------
  # * Draws A1 Tiles
  #--------------------------------------------------------------------------
  def bitmap_for_autotile(autotile)
    return 0 if autotile.between?(0,15)
    return 1 if autotile.between?(16,47)
    return 2 if autotile.between?(48,79)
    return 3 if autotile.between?(80,127)
  end
  #--------------------------------------------------------------------------
  # * Draws A1 Tiles
  #--------------------------------------------------------------------------
  A1 = [
    [13,14,17,18], [2,14,17,18],  [13,3,17,18],  [2,3,17,18],
    [13,14,17,7],  [2,14,17,7],   [13,3,17,7],   [2,3,17,7],
    [13,14,6,18],  [2,14,6,18],   [13,3,6,18],   [2,3,6,18],
    [13,14,6,7],   [2,14,6,7],    [13,3,6,7],    [2,3,6,7],
    [12,14,16,18], [12,3,16,18],  [12,14,16,7],  [12,3,16,7],
    [9,10,17,18],  [9,10,17,7],   [9,10,6,18],   [9,10,6,7],
    [13,15,17,19], [13,15,6,19],  [2,15,17,19],  [2,15,6,19],
    [13,14,21,22], [2,14,21,22],  [13,3,21,22],  [2,3,21,22],
    [12,15,16,19], [9,10,21,22],  [8,9,12,13],   [8,9,12,7],
    [10,11,14,15], [10,11,6,15],  [18,19,22,23], [2,19,22,23],
    [16,17,20,21], [16,3,20,21],  [8,11,12,15],  [8,9,20,21],
    [16,19,20,23], [10,11,22,23], [8,11,20,23],  [0,1,4,5]
  ]
  A1POS = [
  [0,0],[0,TILESIZE*3],[TILESIZE*6,0],[TILESIZE*6,TILESIZE*3],
  [TILESIZE*8,0],[TILESIZE*14,0],[TILESIZE*8,TILESIZE*3],[TILESIZE*14,TILESIZE*3],
  [0,TILESIZE*6],[TILESIZE*6,TILESIZE*6],[0,TILESIZE*9],[TILESIZE*6,TILESIZE*9],
  [TILESIZE*8,TILESIZE*6],[TILESIZE*14,TILESIZE*6],[TILESIZE*8,TILESIZE*9],[TILESIZE*14,TILESIZE*9]
  ]
  def draw_a1_tile(x,y,id,animated = false)
    autotile = (id - 2048) / 48
    return draw_waterfalltile(x,y,id) if [5,7,9,11,13,15].include?(autotile)
    index = (id - 2048) % 48
    case bitmap_for_autotile(autotile)
    when 0
      x2 = A1POS[autotile][0]
      y2 = A1POS[autotile][1]
    when 1
      x2 = (TILESIZE * 2) * ((autotile - 16) % 8)
      y2 = (TILESIZE * 3) * ((autotile - 16) / 8)
    when 2
      x2 = (TILESIZE * 2) * ((autotile - 48) % 8)
      y2 = (TILESIZE * 2) * ((autotile - 48) / 8)
    when 3
      x2 = (TILESIZE * 2) * ((autotile - 80) % 8)
      y2 = (TILESIZE * 3) * ((((autotile - 80) / 8)+1)/2) + (TILESIZE * 2) * (((autotile - 80) / 8)/2)
    end

    rect = Rect.new(0,0,TILESIZE/2,TILESIZE/2)

    for layer in @animated_layer
      for i in 0..3
        rect.x = x2 + (TILESIZE/2) * (A1[index][i] % 4)
        rect.y = y2 + (TILESIZE/2) * (A1[index][i] / 4)
        case i
        when 0
          layer.blt(x * TILESIZE, y * TILESIZE,@bitmaps[bitmap_for_autotile(autotile)],rect)
        when 1
          layer.blt(x * TILESIZE + (TILESIZE/2), y * TILESIZE,@bitmaps[bitmap_for_autotile(autotile)],rect)
        when 2
          layer.blt(x * TILESIZE, y * TILESIZE + (TILESIZE/2),@bitmaps[bitmap_for_autotile(autotile)],rect)
        when 3
          layer.blt(x * TILESIZE + (TILESIZE/2), y * TILESIZE + (TILESIZE/2),@bitmaps[bitmap_for_autotile(autotile)],rect)
        end
      end
      x2 += TILESIZE * 2 if animated && ![2,3].include?(autotile)
    end
  end
  #--------------------------------------------------------------------------
  # * Draws Waterfall Tiles
  #--------------------------------------------------------------------------
  A1E = [[0,1,6,7],[0,1,4,5],[2,3,6,7],[1,2,5,6]]
  def draw_waterfalltile(x,y,id)
    autotile = (id - 2048) / 48
    index = (id - 2048) % 48
      x2 = A1POS[autotile][0]
      y2 = A1POS[autotile][1]

    rect = Rect.new(0,0,TILESIZE/2,TILESIZE/2)

    for layer in @animated_layer
      for i in 0..3
        rect.x = x2 + (TILESIZE/2) * (A1E[index][i] % 4) rescue next
        rect.y = y2 + (TILESIZE/2) * (A1E[index][i] / 4) rescue next
        case i
        when 0
          layer.blt(x * TILESIZE, y * TILESIZE,@bitmaps[bitmap_for_autotile(autotile)],rect)
        when 1
          layer.blt(x * TILESIZE + (TILESIZE/2), y * TILESIZE,@bitmaps[0],rect)
        when 2
          layer.blt(x * TILESIZE, y * TILESIZE + (TILESIZE/2),@bitmaps[0],rect)
        when 3
          layer.blt(x * TILESIZE + (TILESIZE/2), y * TILESIZE + (TILESIZE/2),@bitmaps[0],rect)
        end
      end
      y2 += TILESIZE
    end
  end
  #--------------------------------------------------------------------------
  # * Draws A2 Tiles
  #--------------------------------------------------------------------------
  def draw_a2_tile(x,y,id)
    draw_a1_tile(x,y,id)
  end
  #--------------------------------------------------------------------------
  # * Draws A3 Tiles
  #--------------------------------------------------------------------------
  A3 = [
    [5,6,9,10],    [4,5,8,9],    [1,2,5,6],   [0,1,4,5],
    [6,7,10,11],   [4,7,8,11],   [2,3,6,7],   [0,3,4,7],
    [9,10,13,14],  [8,9,12,13],  [1,2,13,14], [0,1,12,13],
    [10,11,14,15], [8,11,12,13], [2,3,14,15], [0,3,12,15]
    ]
  def draw_a3_tile(x,y,id)
    autotile = (id - 2048) / 48
    index = (id - 2048) % 48
    case bitmap_for_autotile(autotile)
    when 0
      x2 = (TILESIZE * 2) * ((autotile) % 8)
      y2 = (TILESIZE * 3) * ((autotile) / 8)
    when 1
      x2 = (TILESIZE * 2) * ((autotile - 16) % 8)
      y2 = (TILESIZE * 3) * ((autotile - 16) / 8)
    when 2
      x2 = (TILESIZE * 2) * ((autotile - 48) % 8)
      y2 = (TILESIZE * 2) * ((autotile - 48) / 8)
    when 3
      x2 = (TILESIZE * 2) * ((autotile - 80) % 8)
      y2 = (TILESIZE * 3) * ((((autotile - 80) / 8)+1)/2) + (TILESIZE * 2) * (((autotile - 80) / 8)/2)
    end

    rect = Rect.new(0,0,TILESIZE/2,TILESIZE/2)

    for layer in @animated_layer
      for i in 0..3
        if A3[index].nil?
          rect.x = x2 + (TILESIZE/2) * (A1[index][i] % 4)
          rect.y = y2 + (TILESIZE/2) * (A1[index][i] / 4)
        else
          rect.x = x2 + (TILESIZE/2) * (A3[index][i] % 4)
          rect.y = y2 + (TILESIZE/2) * (A3[index][i] / 4)
        end
        case i
        when 0
          layer.blt(x * TILESIZE, y * TILESIZE,@bitmaps[bitmap_for_autotile(autotile)],rect)
        when 1
          layer.blt(x * TILESIZE + (TILESIZE/2), y * TILESIZE,@bitmaps[bitmap_for_autotile(autotile)],rect)
        when 2
          layer.blt(x * TILESIZE, y * TILESIZE + (TILESIZE/2),@bitmaps[bitmap_for_autotile(autotile)],rect)
        when 3
          layer.blt(x * TILESIZE + (TILESIZE/2), y * TILESIZE + (TILESIZE/2),@bitmaps[bitmap_for_autotile(autotile)],rect)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Draws A4 Tiles
  #--------------------------------------------------------------------------
  def draw_a4_tile(x,y,id)
    autotile = (id - 2048) / 48
    case autotile
    when 80..87
      draw_a1_tile(x,y,id)
    when 96..103
      draw_a1_tile(x,y,id)
    when 112..119
      draw_a1_tile(x,y,id)
    else
      draw_a3_tile(x,y,id)
    end
  end
  #--------------------------------------------------------------------------
  # * Draws A5 Tiles
  #--------------------------------------------------------------------------
  def draw_a5_tile(x,y,id)
    id -= 1536
    rect = Rect.new(TILESIZE * (id % 8),TILESIZE * ((id % 128) / 8),TILESIZE,TILESIZE)
    for layer in @animated_layer
      layer.blt(x * TILESIZE, y * TILESIZE,@bitmaps[4],rect)
    end
  end
  #--------------------------------------------------------------------------
  # * Check if animated layer needed
  #--------------------------------------------------------------------------
  def need_animated_layer?
    for x in 0...@map_data.xsize
      for y in 0...@map_data.ysize
        if @map_data[x,y,0].between?(2048, 2815)
          return true
        end
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Draw Upper Layers
  #--------------------------------------------------------------------------
  def draw_upper_layers
    bitmap = Bitmap.new(@map_data.xsize * TILESIZE, @map_data.ysize * TILESIZE)
    @layers[1].bitmap = bitmap
    @layers[2].bitmap = bitmap.dup
    rect = Rect.new(0,0,TILESIZE,TILESIZE)
    for x in 0...@map_data.xsize
      for y in 0...@map_data.ysize
        n = @map_data[x, y, 2] % 0x100
        rect.x = TILESIZE * ((n % 8) + (8 * (n / 128)))
        rect.y = TILESIZE * ((n % 128) / 8)
        if @flags[@map_data[x,y,2]] & 0x10 == 0
          @layers[1].bitmap.blt(x * TILESIZE, y * TILESIZE,@bitmaps[5+@map_data[x,y,2]/256],rect)
        else
          @layers[2].bitmap.blt(x * TILESIZE, y * TILESIZE,@bitmaps[5+@map_data[x,y,2]/256],rect)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Shadow Layer
  #--------------------------------------------------------------------------
  def draw_shadow_layer
    return false
    bitmap = Bitmap.new(@map_data.xsize * TILESIZE, @map_data.ysize * TILESIZE)
    @layer[3].bitmap = bitmap
    shadow_color = Color.new(0, 0, 0, 0x80)
    ts = TILESIZE
    hts = ts / 2 # half-tile size
    for x in 0...@map_data.xsize
      for y in 0...@map_data.ysize
        shadowbit = @map_data[x, y, 3] % 16
        # top-left
        if (shadowbit & 1) == 1
          bitmap.fill_rect(ts * x, ts * y, hts, hts, shadow_color)
        end
        # top-right
        if (shadowbit & 2) == 2
          bitmap.fill_rect(ts * x + hts, ts * y, hts, hts, shadow_color)
        end
        # bottom-left
        if (shadowbit & 4) == 4
          bitmap.fill_rect(ts * x, ts * y + hts,
                           hts, hts, shadow_color)
        end
        # bottom-right
        if (shadowbit & 8) == 8
          bitmap.fill_rect(ts * x + hts, ts * y + hts, hts, hts, shadow_color)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Flash Layer
  #--------------------------------------------------------------------------
  def draw_flash_layer
    return unless @flash_data
    bitmap = Bitmap.new(@flash_data.xsize * TILESIZE,
                        @flash_data.ysize * TILESIZE)
    @layers[4].bitmap = bitmap
    for x in 0...@flash_data.xsize
      for y in 0...@flash_data.ysize
        rgb12 = @flash_data[x, y] & 0x0FFF
        color = @@flash_cache[rgb12] ||= SRRI.rgb12_color(rgb12)
        bitmap.fill_rect(TILESIZE * x, TILESIZE * y, TILESIZE, TILESIZE, color)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Set Map Data
  #--------------------------------------------------------------------------
  def map_data=(data)
    return if @map_data == data
    @map_data = data
    refresh
  end
  #--------------------------------------------------------------------------
  # * Set Flash Data
  #--------------------------------------------------------------------------
  def flash_data=(data)
    return if @flash_data == data
    @flash_data = data
    refresh_flash_data
  end
  #--------------------------------------------------------------------------
  # * Set Map Data
  #--------------------------------------------------------------------------
  def flags=(data)
    @flags = data
    refresh
  end
  #--------------------------------------------------------------------------
  # * Set ox
  #--------------------------------------------------------------------------
  def ox=(value)
    @ox = value
    for layer in @layers
      layer.ox = @ox
    end
  end
  #--------------------------------------------------------------------------
  # * Set oy
  #--------------------------------------------------------------------------
  def oy=(value)
    @oy = value
    for layer in @layers
      layer.oy = @oy
    end
  end
end