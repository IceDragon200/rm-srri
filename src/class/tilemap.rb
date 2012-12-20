class RGX::Tilemap

  include Interface::IDrawable
  include Interface::IDisposable
  include Interface::IZSortable

  def draw(texture)
    #
  end

  def initialize(viewport=nil)
    @bitmaps = Array.new(8, nil)

    @viewport = viewport

    @map_data = Table.new(1, 1, 4)
    @flash_data = nil
    @flags = Table.new(0x1FFE)

    @ox, @oy = 0, 0
    @z       = 0
    @visible = true

    register_drawable
    setup_iz_id
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
