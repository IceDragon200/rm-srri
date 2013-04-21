#
# rm-srri/lib/class/tilemap.rb
# vr 1.0.0
class SRRI::Tilemap

  include SRRI::Interface::IViewport

  TILESIZE = 32

private

  def tile_rect(x, y, _)
    return Rect.new(x * TILESIZE, y * TILESIZE, TILESIZE, TILESIZE)
  end

  def clear_tile(x, y, z)
    @layers[z].clear_rect(tile_rect(x, y, z))
  end

  def draw_tile(x, y, z)
    @layers[z]
  end

  def initialize(viewport=nil)
    @bitmaps = Array.new(8, nil)

    @viewport = viewport

    @map_data   = Table.new(1, 1, 4)
    @flash_data = Table.new(1, 1, 4)
    @flags      = Table.new(0x1FFE)

    @ox, @oy = 0, 0
    @z       = 0
    @visible = true

    register_drawable
    setup_iz_id
  end

public

  def draw(texture)
    #
  end

  def dup
    raise(SRRI.mk_copy_error(self))
  end

  def clone
    raise(SRRI.mk_copy_error(self))
  end

  def dispose
    unregister_drawable
    super
  end

  def update
  end

  attr_reader :ox, :oy, :z,
              :flash_data, :map_data, :flags,
              :viewport,
              :visible, :bitmaps

  def ox=(new_ox)
    @ox = new_ox.to_i
  end

  def oy=(new_oy)
    @oy = new_oy.to_i
  end

  def z=(new_z)
    @z = new_z.to_i
  end

  def bitmaps=(new_bitmaps)
    @bitmaps = new_bitmaps
  end

  def map_data=(new_map_data)
    @map_data = new_map_data
  end

  def flash_data(new_flash_data)
    @flash_data = new_flash_data
  end

  def flags=(new_flags)
    @flags = new_flags
  end

  def visible=(new_visible)
    @visible = !!new_visible
  end

  def viewport=(new_viewport)
    @viewport = new_viewport
  end

end

__END__
# TilesetExport!
# // Started : 07/13/2011
# // Modified: 07/14/2011
# // Waterfalls need to be coded properly

# // Credit to FenixFyreX
module TilesetRanges

  # A1
  A1 = [
    [0,(2048...2096)],[1,(2096...2144)],[1,(2144...2192)],[1,(2192...2240)],
    [0,(2240...2288)],[0,(2288...2336)],[0,(2336...2384)],[0,(2384...2432)],
    [0,(2432...2480)],[0,(2480...2528)],[0,(2528...2576)],[0,(2576...2624)],
    [0,(2624...2672)],[0,(2672...2720)],[0,(2720...2768)],[0,(2768...2816)]
  ]
  # A2
  A2_1 = [
    [0,(2816...2864)],[1,(2864...2912)],[1,(2912...2960)],[0,(2960...3008)],
    [1,(3008...3056)],[1,(3056...3104)],[0,(3104...3152)],[0,(3152...3200)]
  ]
  A2_2 = [
    [0,(3200...3248)],[1,(3248...3296)],[1,(3296...3344)],[0,(3344...3392)],
    [1,(3392...3440)],[1,(3440...3488)],[0,(3488...3536)],[0,(3536...3584)]
  ]
  A2_3 = [
    [0,(3584...3632)],[1,(3632...3680)],[1,(3680...3728)],[0,(3728...3776)],
    [1,(3776...3824)],[1,(3824...3872)],[0,(3872...3920)],[0,(3920...3968)]
  ]
  A2_4 = [
    [0,(3968...4016)],[1,(4016...4064)],[1,(4064...4112)],[0,(4112...4160)],
    [1,(4160...4208)],[1,(4208...4256)],[0,(4256...4304)],[0,(4304...4352)]
  ]
   A2 = A2_1 + A2_2 + A2_3 + A2_4
   # A3
   A3 = []
  for i in 0...32
    n = 4352 + (48*i)
    n2 = n+48
    A3 << [0,n...n2]
  end
   # A4
   A4 = []
  for i in 0...48
    n = 5888 + (48*i)
    n2 = n+48
    A4 << [0,n...n2]
  end
   # A5
   A5 = []
  for i in 1536...1664
    A5 << [0,i...i+1]
  end
   # B
   B = []
  for i in 0...256
    B << [2,i...i+1]
  end
   # C
   C = []
  for i in 256...512
    C << [2,i...i+1]
  end
   # D
   D = []
  for i in 512...768
    D << [2,i...i+1]
  end
   # E

  E = []
  for i in 768...1024
    E << [2,i...i+1]
  end

  # // IceDragon Bit
  A = A1 + A2 + A3 + A4 + A5

  AA= A.collect { |e| e[1] }

end
 # // IceDragon
module ISS ; end
module ISS::TilemapSettings

  Vector2 = Struct.new(:p1, :p2)

  TILESIZE          = Vector2.new(32, 32)
  SEGMENT_SIZE      = Vector2.new(16, 16)
  AUTOTILE_SIZE1    = Vector2.new(64, 96)
  AUTOTILE_SIZE2    = Vector2.new(64, 64)
  # // 64x96
  AUTOTILE_SEGMENTS = [
    [19, 18, 15, 14],
    [ 3, 18, 15, 14],
    [19,  4, 15, 14],
    [ 3,  4, 15, 14],
    [19, 18, 15,  8],
    [ 3, 18, 15,  8],
    [19,  4, 15,  8],
    [ 3,  4, 15,  8],
    [19, 18,  7, 14],
    [ 3, 18,  7, 14],
    [19,  4,  7, 14],
    [ 3,  4,  7, 14],
    [19, 18,  7,  8],
    [ 3, 18,  7,  8],
    [19,  4,  7,  8],
    [ 3,  4,  7,  8],
    [17, 18, 13, 14],
    [17,  4, 13, 14],
    [17, 18, 13,  8],
    [17,  4, 13,  8],
    [11, 10, 15, 14],
    [11, 10, 15,  8],
    [11, 10,  7, 14],
    [11, 10,  7,  8],
    [19, 20, 15, 16],
    [19, 20,  7, 16],
    [ 3, 20, 15, 16],
    [ 3, 20,  7, 16],
    [19, 18, 23, 22],
    [ 3, 18, 23, 22],
    [19,  4, 23, 22],
    [ 3,  4, 23, 22],
    [17, 20, 13, 16],
    [11, 10, 23, 22],
    [ 9, 10, 13, 14],
    [ 9, 10, 13,  8],
    [11, 12, 15, 16],
    [11, 12,  7, 16],
    [19, 20, 23, 24],
    [ 3, 20, 23, 24],
    [17, 18, 21, 22],
    [17,  4, 21, 22],
    [ 9, 12, 13, 16],
    [ 9, 10, 21, 22],
    [17, 20, 21, 24],
    [11, 12, 23, 24],
    [ 9, 12, 21, 24],
    [ 1,  2,  5,  6]
  ]

  # // 64x64
  AUTOTILE_SEGMENTS2 = [
    [11, 10,  7,  6],
    [ 9, 10,  5,  6],
    [ 3,  2,  7,  6],
    [ 1,  2,  5,  6],
    [11, 12,  7,  8],
    [ 9, 12,  5,  8],
    [ 3,  4,  7,  8],
    [ 1,  4,  5,  8],
    [11, 10, 15, 14],
    [ 9, 10, 13, 14],
    [ 3,  2, 15, 14],
    [ 1,  2, 13, 14],
    [11, 12, 15, 16],
    [ 9, 12, 13, 16],
    [ 3,  4, 15, 16],
    [ 1,  4, 13, 16],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1],
    [ 1,  1,  1,  1]
  ]

  # // Fix Offset
  for i in 0...AUTOTILE_SEGMENTS.size
    for i2 in 0...4
      AUTOTILE_SEGMENTS[i][i2] -= 1
    end
  end

  for i in 0...AUTOTILE_SEGMENTS2.size
    for i2 in 0...4
      AUTOTILE_SEGMENTS2[i][i2] -= 1
    end
  end

  PARENT_TILE = []

  # // Setup Parent Tiles for B to E
  for i in 0...1024
    PARENT_TILE[i] = i
  end

  # // Setup Parent Tiles for A1 to A5
  for a1_set in TilesetRanges::AA
    pa = a1_set.to_a[0]
    for i in a1_set
      PARENT_TILE[i] = pa
    end
  end

  # // Redo A5
  TilesetRanges::A5.each { |a5_set| a5_set.each { |e| PARENT_TILE[e] = e } }

  # // Setup Autotile Indexes
  AUTOTILE_INDEX = []

  16.times { |i|
    AUTOTILE_INDEX[2048+(48*i)] = [0, i] # A1 [tileset_id, tileset_index]
  }

  32.times { |i|
    AUTOTILE_INDEX[2816+(48*i)] = [1, i] # A2 [tileset_id, tileset_index]
    AUTOTILE_INDEX[4352+(48*i)] = [2, i] # A3 [tileset_id, tileset_index]
  }

  48.times { |i|
    AUTOTILE_INDEX[5888+(48*i)] = [3, i] # A4 [tileset_id, tileset_index]
  }
   A4_TILE_POSITIONS = Array.new(56)
  at1w, at1h = AUTOTILE_SIZE1.p1, AUTOTILE_SIZE1.p2
  at2w, at2h = AUTOTILE_SIZE2.p1, AUTOTILE_SIZE2.p2

  8.times { |i|
  # // Roofs
    A4_TILE_POSITIONS[i]    = Vector2.new(i*at1w, 0)
    A4_TILE_POSITIONS[i+16] = Vector2.new(i*at1w, at1h+at2h)
    A4_TILE_POSITIONS[i+32] = Vector2.new(i*at1w, (at1h*2)+(at2h*2))
  # // Walls
    A4_TILE_POSITIONS[i+8]  = Vector2.new(i*at1h, at1h)
    A4_TILE_POSITIONS[i+24] = Vector2.new(i*at1h, (at1h*2)+at2h)
    A4_TILE_POSITIONS[i+40] = Vector2.new(i*at1h, (at1h*3)+(at2h*2))
  }

  module_function()

  def get_segment_set(tile_id)
    case tileset_family(tile_id)
    when :a3
      return AUTOTILE_SEGMENTS2[tile_id-PARENT_TILE[tile_id]]
    when :a4
      tileset, index = *AUTOTILE_INDEX[PARENT_TILE[tile_id]]
      roof = (index / 8) % 2 == 0
      return AUTOTILE_SEGMENTS[tile_id-PARENT_TILE[tile_id]] if roof
      return AUTOTILE_SEGMENTS2[tile_id-PARENT_TILE[tile_id]]
    else
      return AUTOTILE_SEGMENTS[tile_id-PARENT_TILE[tile_id]]
    end
  end

  def get_autotile_bit( xo, yo, bitmap, tile_bit )
    bitm = Bitmap.new(SEGMENT_SIZE.p1, SEGMENT_SIZE.p2)
    rect = Rect.new(
     SEGMENT_SIZE.p1*(tile_bit%4)+xo, SEGMENT_SIZE.p2*(tile_bit/4)+yo, # // x, y
     SEGMENT_SIZE.p1, SEGMENT_SIZE.p2) # // width, height
    bitm.blt(0, 0, bitmap, rect)
    return bitm
  end

  def tileset_family(tile_id)
    case tile_id
    when 0...1024            ; return :be
    when 2048...2816         ; return :a1
    when 2816...4352         ; return :a2
    when 4352...5888         ; return :a3
    when 5888...8192         ; return :a4
    when 1536...1664         ; return :a5
    end
  end

  def anim_autotile?( tile_id, type )
    case type
    when 0 # // Normal
      case tile_id
      when 2048...2096, 2144...2192, 2240...2288, 2336...2384, 2432...2480,
       2528...2576, 2624...2672, 2720...2768
        return true
      end
    when 1 # // Waterfall
      case tile_id
      when 2288...2336, 2384...2432, 2480...2528, 2576...2624,
       2672...2720, 2768...2816
        return true
      end
    end
    return false
  end

  def get_autotile( bitmaps, tile_id )
    tileset, index = *AUTOTILE_INDEX[PARENT_TILE[tile_id]]
    bmp  = bitmaps[tileset]
    segs = get_segment_set(tile_id)
    bitm = Bitmap.new(TILESIZE.p1, TILESIZE.p2)
    tf = tileset_family(tile_id)
    ats  = case tf
           when :be, :a1, :a2    ; [AUTOTILE_SIZE1]
           when :a3              ; [AUTOTILE_SIZE2]
           when :a4              ; [] # // Unused
           end
    for i in 0...segs.size
      seg = segs[i]
      case tf
      when :a4
        as  = A4_TILE_POSITIONS[index]
        ab  = get_autotile_bit( as.p1, as.p2, bmp, seg )
      else
        x, y = (index%8), (index/8)
        as   = ats[y % ats.size]
        ab  = get_autotile_bit( as.p1*x, as.p2*y, bmp, seg )
       end
      bitm.blt(SEGMENT_SIZE.p1*(i%2), SEGMENT_SIZE.p2*(i/2), ab, ab.rect)
      ab.dispose()
    end
    return bitm
  end

  def get_normaltile( bitmap, index )
    bitm = Bitmap.new(TILESIZE.p1, TILESIZE.p2)
    sx = (index / 128 % 2 * 8 + index % 8) * TILESIZE.p1;
    sy = index % 256 / 8 % 16 * TILESIZE.p2;
    rect = Rect.new(sx, sy, TILESIZE.p1, TILESIZE.p2)
    bitm.blt(0, 0, bitmap, rect)
    return bitm
  end

  def get_a5tile( bitmap, index )
    index = index-1536
    bitm = Bitmap.new(TILESIZE.p1, TILESIZE.p2)
    sx = TILESIZE.p1 * (index%8)
    sy = TILESIZE.p2 * (index/8)
    rect = Rect.new(sx, sy, TILESIZE.p1, TILESIZE.p2)
    bitm.blt(0, 0, bitmap, rect)
    return bitm
  end

  def tileset_bitmap(bitmaps, tile_id)
    set_number = tile_id / 256
    return bitmaps[5] if set_number == 0
    return bitmaps[6] if set_number == 1
    return bitmaps[7] if set_number == 2
    return bitmaps[8] if set_number == 3
    return nil
  end

  def get_tile_bit(bitmaps, tile_id)
    #File.open("output.log", "a") { |f| f.puts("#{tile_id}") }
    case tile_id
    # // B..E
    when 0...1024
      return get_normaltile(tileset_bitmap(bitmaps, tile_id), tile_id)
    when 1536...1664
      return get_a5tile(bitmaps[4], tile_id)
    when 2048...8192
      return get_autotile(bitmaps, tile_id)
    else
      return Bitmap.new(32, 32)
    end
    return nil
  end

  def get_waterfalltile_bit( bitmaps, tile_id, frame )
    return Bitmap.new(32, 32)
  end

  def save_tileset( id )
    bmp = Bitmap.new( 8*32, (8192/8)*32 )
    bmps = []
    @tileset = Database.tilesets[id]
    @tileset.tileset_names.each_with_index do |name, i|
      bmps[i] = Cache.tileset(name)
    end
    GC.start()
    for i in 0...8192
      bit = get_tile_bit(bmps, i)
      bmp.blt((i%8)*32, (i/8)*32, bit, bit.rect)
      bit.dispose
      puts "Block List Transfering Tile: #{i}"
      sleep(0.1) if i % 512 == 0
    end
    puts "Writing PNG"
    bmp.write_png( "#{@tileset.name}(Tileset).png" )
  end
end
#ISS::TilemapSettings.save_tileset( 0 )
