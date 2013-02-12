#!/usr/bin/env ruby
# lib-exp/sr-chipmap.rb
# vr 1.0
require_relative 'color-addons'

class RGX::SrChipmap

  class ChipmapError < StandardError
    #
  end

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
      @ox, @oy, @width, @height,
      @opacity, 1
    )
  end

  attr_accessor :map_data, :tilesize, :tile_bitmap, :tile_columns
  attr_reader :opacity, :x, :y, :z, :width, :height, :ox, :oy

  def initialize
    @tilesize = 32
    @tile_columns = 16

    @visible = true

    @opacity = 255
    @x, @y, @width, @height = 0, 0, 0, 0
    @z = 0
    @ox, @oy = 0, 0

    @map_data = nil
    @tile_bitmap = nil

    @disposed = false

    register_drawable
    setup_iz_id
  end

  def dispose
    @texture.dispose
    @texture = nil
    @disposed = true
    unregister_drawable
  end

  def disposed?
    return !!@disposed
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

  def ox=(new_ox)
    @ox = new_ox.to_i
  end

  def oy=(new_oy)
    @oy = new_oy.to_i
  end

  def width=(new_width)
    @width = new_width.to_i
  end

  def height=(new_height)
    @height = new_height.to_i
  end

  def opacity=(new_opacity)
    @opacity = [[new_opacity.to_i, 0].max, 255].min
  end

  def refresh
    raise(ChipmapError, "map_data has not been set") unless @map_data
    raise(ChipmapError, "tile_bitmap has not been set") unless @tile_bitmap

    pxw, pxh = @tilesize * @map_data.xsize, @tilesize * @map_data.ysize
    @texture = StarRuby::Texture.new(pxw, pxh)
    @texture.clear

    for y in 0...@map_data.ysize
      for x in 0...@map_data.xsize
        draw_tile(x, y)
      end
    end

    return true
  end

  def update
    # flash table
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
    @texture.fill_rect(
      r.x, r.y, r.width, r.height, StarRuby::Color::TransparentColor)
  end

  def draw_tile(x, y)
    tx, ty = index_to_xy(@map_data[x, y])

    r = tile_rect(x, y)
    tr = tile_rect(tx, ty)

    TextureTool.render_texture_fast(
      @texture, r.x, r.y,
      @tile_bitmap.texture,
      tr.x, tr.y, tr.width, tr.height,
      255, 1
    )
  end

  def redraw_tile(x, y)
    clear_tile(x, y)
    draw_tile(x, y)
  end

end
