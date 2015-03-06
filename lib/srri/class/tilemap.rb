require 'srri/core_ext/integer'
require 'srri/class/table'
require 'srri/class/color'
require 'srri/interface/i_renderable'
require 'srri/interface/i_z_order'
require 'srri/core/null_out'

module SRRI
  # Based on Fomar0153's Tilemap.
  #   This is a edit of Formar0153's Tilemap, with changes and fixes to fit
  #   the SRRI implementation.
  class Tilemap
    class BitmapArray
      def initialize(parent)
        @parent = parent
        @data = Array.new(8) { nil }
      end

      def [](index)
        @data[index]
      end

      def []=(index, value)
        @data[index] = value
        @parent.on_bitmap_change
      end
    end

    include Interface::IRenderable
    include Interface::IZOrder

    #register_renderable('Tilemap')

    #--------------------------------------------------------------------------
    # * Constants
    #--------------------------------------------------------------------------
    MICRO_TILE_IDS_WATERFALL = [
      [ 2,  1,  6,  5],
      [ 0,  1,  4,  5],
      [ 2,  3,  6,  7],
      [ 0,  3,  4,  7],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
    ].map(&:freeze).freeze

    MICRO_TILE_IDS_2x2 = [
      [10,  9,  6,  5],
      [ 8,  9,  4,  5],
      [ 2,  1,  6,  5],
      [ 0,  1,  4,  5],
      [10, 11,  6,  7],
      [ 8, 11,  4,  7],
      [ 2,  3,  6,  7],
      [ 0,  3,  4,  7],
      [10,  9, 14, 13],
      [ 8,  9, 12, 13],
      [ 2,  1, 14, 13],
      [ 0,  1, 12, 13],
      [10, 11, 14, 15],
      [ 8, 11, 12, 15],
      [ 2,  3, 14, 15],
      [ 0,  3, 12, 15],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0],
      [ 0,  0,  0,  0]
    ].map(&:freeze).freeze

    MICRO_TILE_IDS_2x3 = [
      [18, 17, 14, 13],
      [ 2, 17, 14, 13],
      [18,  3, 14, 13],
      [ 2,  3, 14, 13],
      [18, 17, 14,  7],
      [ 2, 17, 14,  7],
      [18,  3, 14,  7],
      [ 2,  3, 14,  7],
      [18, 17,  6, 13],
      [ 2, 17,  6, 13],
      [18,  3,  6, 13],
      [ 2,  3,  6, 13],
      [18, 17,  6,  7],
      [ 2, 17,  6,  7],
      [18,  3,  6,  7],
      [ 2,  3,  6,  7],
      [16, 17, 12, 13],
      [16,  3, 12, 13],
      [16, 17, 12,  7],
      [16,  3, 12,  7],
      [10,  9, 14, 13],
      [10,  9, 14,  7],
      [10,  9,  6, 13],
      [10,  9,  6,  7],
      [18, 19, 14, 15],
      [18, 19,  6, 15],
      [ 2, 19, 14, 15],
      [ 2, 19,  6, 15],
      [18, 17, 22, 21],
      [ 2, 17, 22, 21],
      [18,  3, 22, 21],
      [ 2,  3, 22, 21],
      [16, 19, 12, 15],
      [10,  9, 22, 21],
      [ 8,  9, 12, 13],
      [ 8,  9, 12,  7],
      [10, 11, 14, 15],
      [10, 11,  6, 15],
      [18, 19, 22, 23],
      [ 2, 19, 22, 23],
      [16, 17, 20, 21],
      [16,  3, 20, 21],
      [ 8, 11, 12, 15],
      [ 8,  9, 20, 21],
      [16, 19, 20, 23],
      [10, 11, 22, 23],
      [ 8, 11, 20, 23],
      [ 0,  1,  4,  5]
    ].map(&:freeze).freeze

    WATERFALL_AUTOTILE_IDS = [5, 7, 9, 11, 13, 15].freeze

    TILESIZE = 32
    TILESIZE2 = 64
    TILESIZE3 = 96
    MICRO_TILESIZE = 16
    KEY_X = 0
    KEY_Y = 1
    KEY_DRAWING_RULE = 2
    DRAWING_RULE_NONE = -1
    DRAWING_RULE_MICRO_TILE = 0
    DRAWING_RULE_WATERFALL = 1
    DRAWING_RULE_2x2 = 2
    DRAWING_RULE_2x3 = 3
    DATA_TABLE_SIZE = 3
    TILE_A1_RANGE = (2048...2816).freeze
    TILE_A2_RANGE = (2816...4352).freeze
    TILE_A3_RANGE = (4352...5888).freeze
    TILE_A4_RANGE = (5888...8192).freeze
    TILE_A5_RANGE = (1536...1664).freeze
    TILE_A1_AUTOTILE_RANGE = (0...32).freeze
    TILE_A2_AUTOTILE_RANGE = (32...64).freeze
    TILE_A3_AUTOTILE_RANGE = (64...96).freeze
    TILE_A4_AUTOTILE_RANGE = (96...144).freeze

    MICRO_TILE_SETTINGS = Table.new(24, DATA_TABLE_SIZE)
    MICRO_TILE_SETTINGS.xsize.times do |i|
      x = i % 4
      y = i / 4
      MICRO_TILE_SETTINGS[i, KEY_X] = x * MICRO_TILESIZE
      MICRO_TILE_SETTINGS[i, KEY_Y] = y * MICRO_TILESIZE
      MICRO_TILE_SETTINGS[i, KEY_DRAWING_RULE] = DRAWING_RULE_MICRO_TILE
    end
    MICRO_TILE_SETTINGS.freeze


    TILE_A1_SETTINGS = Table.new(32, DATA_TABLE_SIZE)
    TILE_A1_SETTINGS.xsize.times do |i|
      x = i % 8
      y = i / 8
      TILE_A1_SETTINGS[i, KEY_X] = x * TILESIZE2
      TILE_A1_SETTINGS[i, KEY_Y] = y * TILESIZE3
      TILE_A1_SETTINGS[i, KEY_DRAWING_RULE] = begin
        case i
        when 7, 11, 15, 19, 23, 27, 31
          DRAWING_RULE_WATERFALL
        else
          DRAWING_RULE_2x3
        end
      end
    end
    TILE_A1_SETTINGS.freeze

    TILE_A2_SETTINGS = Table.new(32, DATA_TABLE_SIZE)
    TILE_A2_SETTINGS.xsize.times do |i|
      x = i % 8
      y = i / 8
      TILE_A2_SETTINGS[i, KEY_X] = x * TILESIZE2
      TILE_A2_SETTINGS[i, KEY_Y] = y * TILESIZE3
      TILE_A2_SETTINGS[i, KEY_DRAWING_RULE] = DRAWING_RULE_2x3
    end
    TILE_A2_SETTINGS.freeze

    TILE_A3_SETTINGS = Table.new(32, DATA_TABLE_SIZE)
    TILE_A3_SETTINGS.xsize.times do |i|
      x = i % 8
      y = i / 8
      TILE_A3_SETTINGS[i, KEY_X] = x * TILESIZE2
      TILE_A3_SETTINGS[i, KEY_Y] = y * TILESIZE2
      TILE_A3_SETTINGS[i, KEY_DRAWING_RULE] = DRAWING_RULE_2x2
    end
    TILE_A3_SETTINGS.freeze

    TILE_A4_SETTINGS = Table.new(48, DATA_TABLE_SIZE)
    TILE_A4_SETTINGS.xsize.times do |i|
      x = i % 8
      y = i / 8
      ceiling = y % 2 == 0
      ypos = y.times.reduce(0) { |r, v| r + (v % 2 == 0 ? TILESIZE3 : TILESIZE2) }
      TILE_A4_SETTINGS[i, KEY_X] = x * TILESIZE2
      TILE_A4_SETTINGS[i, KEY_Y] = ypos
      TILE_A4_SETTINGS[i, KEY_DRAWING_RULE] = ceiling ? DRAWING_RULE_2x3 :
                                                        DRAWING_RULE_2x2
    end
    TILE_A4_SETTINGS.freeze

    # AUTOTILE_LOCAL, this will localize the index to the corresponding TILE_*_SETTINGS
    # Simply pass in the autotile_id and it will return the localized index of the autotile
    size = TILE_A1_SETTINGS.xsize + TILE_A2_SETTINGS.xsize +
           TILE_A3_SETTINGS.xsize + TILE_A4_SETTINGS.xsize
    offset = 0
    AUTOTILE_LOCAL = Table.new(size)
    TILE_A1_SETTINGS.xsize.times do |x|
      AUTOTILE_LOCAL[offset + x] = x
    end
    offset += TILE_A1_SETTINGS.xsize
    TILE_A2_SETTINGS.xsize.times do |x|
      AUTOTILE_LOCAL[offset + x] = x
    end
    offset += TILE_A2_SETTINGS.xsize
    TILE_A3_SETTINGS.xsize.times do |x|
      AUTOTILE_LOCAL[offset + x] = x
    end
    offset += TILE_A3_SETTINGS.xsize
    TILE_A4_SETTINGS.xsize.times do |x|
      AUTOTILE_LOCAL[offset + x] = x
    end
    AUTOTILE_LOCAL.freeze

    # AUTOTILE_A1_EXPAND, this will expand a compressed A1 autotile id,
    # normally A1 ids will skip a few tiles, since they're animated.
    AUTOTILE_A1_EXPAND = Table.new(16)
    AUTOTILE_A1_EXPAND[0]  = 0
    AUTOTILE_A1_EXPAND[1]  = 3
    AUTOTILE_A1_EXPAND[2]  = 4
    AUTOTILE_A1_EXPAND[3]  = 7
    AUTOTILE_A1_EXPAND[4]  = 8
    AUTOTILE_A1_EXPAND[5]  = 11
    AUTOTILE_A1_EXPAND[6]  = 12
    AUTOTILE_A1_EXPAND[7]  = 15
    AUTOTILE_A1_EXPAND[8]  = 16
    AUTOTILE_A1_EXPAND[9]  = 19
    AUTOTILE_A1_EXPAND[10] = 20
    AUTOTILE_A1_EXPAND[11] = 23
    AUTOTILE_A1_EXPAND[12] = 24
    AUTOTILE_A1_EXPAND[13] = 27
    AUTOTILE_A1_EXPAND[14] = 28
    AUTOTILE_A1_EXPAND[15] = 31
    AUTOTILE_A1_EXPAND.freeze

    LAYER_GROUND = 0
    LAYER_MID    = 1
    LAYER_ABOVE  = 2
    LAYER_SHADOW = 3
    LAYER_FLASH  = 4

    @@flash_cache = {}

    # @return [BitmapArray]
    attr_accessor :bitmaps
    # @return [IO]
    attr_accessor :debug
    attr_reader   :map_data
    attr_reader   :flash_data
    attr_accessor :flags
    attr_reader   :viewport
    attr_accessor :visible
    attr_reader   :ox
    attr_reader   :oy

    # @param [Viewport] viewport
    def initialize(viewport = nil)
      @debug = NullOut.new
      @bitmaps = BitmapArray.new(self)
      @visible = true
      @ox = 0
      @oy = 0
      @animated_layers = []
      @layers = Array.new(5) { layer_class.new }
      @anim_count = 0
      @_disposed = false
      @layers[LAYER_GROUND].z = 0
      @layers[LAYER_MID].z = 100
      @layers[LAYER_ABOVE].z = 200
      @layers[LAYER_SHADOW].z = 201       # Shadow Layer
      @layers[LAYER_FLASH].z = 202        # Flash Layer (More like static Color)
      @layers[LAYER_FLASH].blend_type = 1 # add blend
      #register_renderable
      setup_renderable_id
      self.viewport = viewport
    end

    # @return [Class]
    def layer_class
      Sprite
    end
    private :layer_class

    #--------------------------------------------------------------------------
    # Positions are faked for Tilemap in order for the Renderable interface to
    # work correctly.
    #--------------------------------------------------------------------------

    # @return [Integer]
    def x
      0
    end

    # @return [Integer]
    def y
      0
    end

    # @return [Integer]
    def z
      0
    end

    def need_animated_layers?
      for x in 0...@map_data.xsize
        for y in 0...@map_data.ysize
          if @map_data[x,y,0].between?(2048, 2815)
            return true
          end
        end
      end
      return false
    end
    private :need_animated_layers?

    def dispose
      super
      for layer in @layers
        layer.bitmap.dispose if layer.bitmap && !layer.bitmap.disposed?
        layer.dispose
      end
      for layer in @animated_layers
        layer.dispose unless layer.disposed?
      end
    end

    def update
      @anim_count = (@anim_count + 1) % [(@animated_layers.size * 30), 1].max
      @layers[0].bitmap = @animated_layers[@anim_count / 30]
      # flash layer
      #@layers[4].opacity = 0x80 + 0x7F * @anim_count / 30.0
    end

    def bitmap_id_for_autotile(autotile)
      case autotile
      when TILE_A1_AUTOTILE_RANGE then 0
      when TILE_A2_AUTOTILE_RANGE then 1
      when TILE_A3_AUTOTILE_RANGE then 2
      when TILE_A4_AUTOTILE_RANGE then 3
      else
        fail "Autotile (#{autotile}) out of range"
      end
    end
    private :bitmap_id_for_autotile

    # @return [Bitmap]
    def bitmap_for_autotile(autotile)
      @bitmaps[bitmap_id_for_autotile(autotile)]
    end
    private :bitmap_for_autotile

    def settings_for_autotile(autotile)
      case autotile
      when TILE_A1_AUTOTILE_RANGE then TILE_A1_SETTINGS
      when TILE_A2_AUTOTILE_RANGE then TILE_A2_SETTINGS
      when TILE_A3_AUTOTILE_RANGE then TILE_A3_SETTINGS
      when TILE_A4_AUTOTILE_RANGE then TILE_A4_SETTINGS
      else
        fail 'Invalid autotile'
      end
    end
    private :settings_for_autotile

    def adjust_autotile_id(autotile)
      if autotile >= 16
        autotile + 16
      else
        @debug.puts "Expanding autotile_id: #{autotile}"
        AUTOTILE_A1_EXPAND[autotile]
      end
    end
    private :adjust_autotile_id

    def draw_microtiles(micro_tiles, dest_bitmap, x, y, src_bitmap, sx, sy)
      micro_tiles.each_with_index do |m, i|
        mx = MICRO_TILE_SETTINGS[m, KEY_X]
        my = MICRO_TILE_SETTINGS[m, KEY_Y]
        dest_bitmap.blt(x + (i % 2) * MICRO_TILESIZE, y + (i / 2) * MICRO_TILESIZE,
                        src_bitmap,
                        Rect.new(sx + mx, sy + my,
                                 MICRO_TILESIZE, MICRO_TILESIZE))
      end
    end
    private :draw_microtiles

    def draw_2x2_autotile(micro_index, *args)
      draw_microtiles(MICRO_TILE_IDS_2x2[micro_index], *args)
    end
    private :draw_2x2_autotile

    def draw_2x3_autotile(micro_index, *args)
      draw_microtiles(MICRO_TILE_IDS_2x3[micro_index], *args)
    end
    private :draw_2x3_autotile

    def draw_waterfall_tile(micro_index, *args)
      draw_microtiles(MICRO_TILE_IDS_WATERFALL[micro_index], *args)
    end
    private :draw_waterfall_tile

    # draw all the other tile 1/2/3/4
    def draw_tile_a_other(x, y, id)
      autotile = adjust_autotile_id((id - 2048) / 48)
      index = (id - 2048) % 48
      a1 = autotile < 32
      settings = settings_for_autotile(autotile)
      local = AUTOTILE_LOCAL[autotile]
      bmp = bitmap_for_autotile(autotile)
      tx = settings[local, KEY_X]
      ty = settings[local, KEY_Y]
      rule = settings[local, KEY_DRAWING_RULE]
      dx, dy = x * TILESIZE, y * TILESIZE
      @animated_layers.each_with_index do |l, i|
        sx = tx
        sy = ty
        case rule
        when DRAWING_RULE_WATERFALL
          @debug.puts "Drawing Waterfall: autotile=#{autotile} frame=#{i} from=#{[sx, sy]}"
          sy += i * TILESIZE
          draw_waterfall_tile(index, l, dx, dy, bmp, sx, sy)
        when DRAWING_RULE_2x2
          @debug.puts "Drawing 2x2: autotile=#{autotile}  from=#{[sx, sy]}"
          draw_2x2_autotile(index, l, dx, dy, bmp, sx, sy)
        when DRAWING_RULE_2x3
          @debug.puts "Drawing 2x3: autotile=#{autotile} frame=#{i} from=#{[sx, sy]}"
          sx += i * TILESIZE2 if a1
          draw_2x3_autotile(index, l, dx, dy, bmp, sx, sy)
        else
          fail "Invalid DRAWING_RULE #{rule}"
        end
      end
    end

    def draw_tile_a1(x, y, id)
      draw_tile_a_other(x, y, id)
    end
    private :draw_tile_a1

    def draw_tile_a2(x, y, id)
      draw_tile_a_other(x, y, id)
    end
    private :draw_tile_a2

    def draw_tile_a3(x, y, id)
      draw_tile_a_other(x, y, id)
    end
    private :draw_tile_a3

    def draw_tile_a4(x, y, id)
      draw_tile_a_other(x, y, id)
    end
    private :draw_tile_a4

    def draw_tile_a5(x, y, id)
      id -= 1536
      rect = Rect.new(TILESIZE * (id % 8), TILESIZE * ((id % 128) / 8),
                      TILESIZE, TILESIZE)
      for layer in @animated_layers
        layer.blt(x * TILESIZE, y * TILESIZE, @bitmaps[4], rect)
      end
    end
    private :draw_tile_a5

    def draw_b_e_layers
      width, height = @map_data.xsize * TILESIZE, @map_data.ysize * TILESIZE
      @layers[LAYER_MID].bitmap = Bitmap.new(width, height)
      @layers[LAYER_ABOVE].bitmap = Bitmap.new(width, height)
      rect = Rect.new(0, 0, TILESIZE, TILESIZE)
      for x in 0...@map_data.xsize
        for y in 0...@map_data.ysize
          n = @map_data[x, y, 2] % 0x100
          rect.x = TILESIZE * ((n % 8) + (8 * (n / 128)))
          rect.y = TILESIZE * ((n % 128) / 8)
          tx = x * TILESIZE
          ty = y * TILESIZE
          b = @bitmaps[5 + @map_data[x, y, 2] / 256]
          flag = @flags[@map_data[x, y, 2]]
          # is star layer?
          bmps = if flag.flag?(0b10000)
            [@layers[LAYER_ABOVE].bitmap]
          # all impassable, therefore a mid layer
          elsif flag.flag?(0b1111)
            [@layers[LAYER_MID].bitmap]
          # somewhat passable, ground layer
          else
            @animated_layers
          end
          bmps.each { |bmp| bmp.blt(tx, ty, b, rect) }
        end
      end
    end
    private :draw_b_e_layers

    def draw_shadow_layer
      bitmap = Bitmap.new(@map_data.xsize * TILESIZE, @map_data.ysize * TILESIZE)
      @layers[LAYER_SHADOW].bitmap = bitmap
      shadow_color = Color.new(0, 0, 0, 0x80)
      ts = TILESIZE
      hts = MICRO_TILESIZE
      for x in 0...@map_data.xsize
        for y in 0...@map_data.ysize
          shadowbit = @map_data[x, y, 3] % 16
          # top-left
          if shadowbit.flag?(0b0001)
            bitmap.fill_rect(ts * x, ts * y, hts, hts, shadow_color)
          end
          # top-right
          if shadowbit.flag?(0b0010)
            bitmap.fill_rect(ts * x + hts, ts * y, hts, hts, shadow_color)
          end
          # bottom-left
          if shadowbit.flag?(0b0100)
            bitmap.fill_rect(ts * x, ts * y + hts, hts, hts, shadow_color)
          end
          # bottom-right
          if shadowbit.flag?(0b1000)
            bitmap.fill_rect(ts * x + hts, ts * y + hts, hts, hts, shadow_color)
          end
        end
      end
    end
    private :draw_shadow_layer

    def draw_flash_layer
      return unless @flash_data
      bitmap = Bitmap.new(@flash_data.xsize * TILESIZE,
                          @flash_data.ysize * TILESIZE)
      @layers[LAYER_FLASH].bitmap = bitmap
      for x in 0...@flash_data.xsize
        for y in 0...@flash_data.ysize
          rgb12 = @flash_data[x, y] & 0x0FFF
          color = @@flash_cache[rgb12] ||= SRRI.rgb12_color(rgb12)
          bitmap.fill_rect(TILESIZE * x, TILESIZE * y, TILESIZE, TILESIZE, color)
        end
      end
    end
    private :draw_flash_layer

    def draw_animated_layers
      width, height = @map_data.xsize * TILESIZE, @map_data.ysize * TILESIZE
      size = need_animated_layers? ? 3 : 1
      @animated_layers = Array.new(size) { Bitmap.new(width, height) }
      @layers[LAYER_GROUND].bitmap = @animated_layers[0]
      @map_data.ysize.times do |y|
        @map_data.xsize.times do |x|
          2.times do |z|
            case tile_id = @map_data[x, y, z]
            when TILE_A5_RANGE then draw_tile_a5(x, y, tile_id)
            when TILE_A1_RANGE then draw_tile_a1(x, y, tile_id)
            when TILE_A2_RANGE then draw_tile_a2(x, y, tile_id)
            when TILE_A3_RANGE then draw_tile_a3(x, y, tile_id)
            when TILE_A4_RANGE then draw_tile_a4(x, y, tile_id)
            else
              @debug.puts "tile_id #{tile_id} is not in any known range" if tile_id > 0
            end
          end
        end
      end
    end
    private :draw_animated_layers

    def refresh_flash_data
      if @layers[LAYER_FLASH].bitmap && !@layers[LAYER_FLASH].bitmap.disposed?
        @layers[LAYER_FLASH].bitmap.dispose
      end
      draw_flash_layer
    end
    private :refresh_flash_data

    def refresh
      return if @map_data.nil? || @flags.nil?
      @animated_layers.each(&:dispose)
      @animated_layers.clear
      for layer in @layers
        layer.bitmap.dispose if layer.bitmap && !layer.bitmap.disposed?
        layer.bitmap = nil
      end
      draw_animated_layers
      draw_b_e_layers
      draw_shadow_layer
      refresh_flash_data
    end
    #private :refresh

    def on_bitmap_change
      refresh
    end

    def on_map_data_change
      refresh
    end

    def on_flash_data_change
      refresh_flash_data
    end

    def on_flags_change
      refresh
    end

    # @param [Viewport] viewport
    def viewport=(viewport)
      super viewport
      for layer in @layers
        layer.viewport = @viewport
      end
    end

    def map_data=(data)
      return if @map_data == data
      @map_data = data
      on_map_data_change
    end

    def flash_data=(data)
      return if @flash_data == data
      @flash_data = data
      on_flash_data_change
    end

    def flags=(data)
      @flags = data
      on_flags_change
    end

    def ox=(value)
      @ox = value
      for layer in @layers
        layer.ox = @ox
      end
    end

    def oy=(value)
      @oy = value
      for layer in @layers
        layer.oy = @oy
      end
    end
  end
end
