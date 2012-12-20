#
# src/class/plane.rb
#

##
# class Plane
#
class RGX::Plane

  include Interface::IDrawable
  include Interface::IDisposable
  include Interface::IZSortable

  def draw(texture)
    return false unless @bitmap
    return false unless @visible
    return false if @opacity == 0

    view = @viewport || Graphics

    (view).translate(0, 0) do |vx, vy, vrect|
      rx, ry = vx, vy
      vw, vh = view.rect.width, view.rect.height

      sx, sy, sw, sh = 0, 0, vw, vh

      # cropping
      dx = vrect.x - rx
      dy = vrect.y - ry
      dw = (rx + sw) - (vrect.x + vrect.width)
      dh = (ry + sh) - (vrect.y + vrect.height)

      (rx += dx; sx += dx; sw -= dx) if dx > 0
      (ry += dy; sy += dy; sh -= dy) if dy > 0
      sw -= dw if dw > 0
      sh -= dh if dh > 0

      src_texture = @bitmap.texture

      tr, tg, tb, ta = @tone.as_ary

      TextureTool.loop_texture(
        texture, Rect.new(rx, ry, vw, vh),
        src_texture, src_texture.rect,
        @ox, @oy, alpha: @opacity,
        blend_type: Sprite::STARRUBY_BLEND_TYPE[@blend_type],
        scale_x: @zoom_x, scale_y: @zoom_y,
        tone_red: tr, tone_green: tg, tone_blue: tb, saturation: ta
      )

    end
  end

  def initialize(viewport=nil)
    @viewport = viewport
    @bitmap = nil
    @ox, @oy, @z = 0, 0, 0

    @opacity = 255

    @zoom_x, @zoom_y = 1.0, 1.0

    @visible = true

    @blend_type = 0

    @tone = Tone.new
    @color = Color.new

    register_drawable
    setup_iz_id
  end

  attr_reader :z, :ox, :oy,
              :zoom_x, :zoom_y,
              :bitmap, :viewport,
              :visible, :opacity,
              :blend_type,
              :color, :tone

  def dispose
    unregister_drawable
    super
  end

  def bitmap=(new_bitmap)
    @bitmap = new_bitmap
  end

  def viewport=(new_viewport)
    @viewport = new_viewport
    super(@viewport)
  end

  def visible=(vis)
    @visible = !!vis
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

  def ox=(new_ox)
    @ox = new_ox.to_i
  end

  def oy=(new_oy)
    @oy = new_oy.to_i
  end

  def zoom_x=(new_zoom_x)
    @zoom_x = new_zoom_x.to_f
  end

  def zoom_y=(new_zoom_y)
    @zoom_y = new_zoom_y.to_f
  end

  def opacity=(new_opacity)
    @opacity = new_opacity.to_i
  end

  def blend_type=(new_blend_type)
    @blend_type = new_blend_type.to_i
  end

  def color=(new_color)
    @color = new_color
  end

  def tone=(new_tone)
    @tone = new_tone
  end

end