##
# class Sprite
#
# Currently Available
#   opacity (using alpha blend mode only)
#   blend_type
#   src_rect
#
class RGX::Sprite

  include Interface::IDrawable
  include Interface::IDisposable
  include Interface::IZSortable

  STARRUBY_BLEND_TYPE = [
    # RGSS
    :alpha, # 0
    :add,   # 1
    :sub,   # 2

    # StarRuby
    :none,  # 3
    :mask,  # 4
  ]

  def draw(texture)
    return false unless @bitmap
    return false unless @visible
    return false if @opacity == 0
    return false unless @src_rect
    return false if @src_rect.empty?

    (viewport || Graphics).translate(@x, @y) do |vx, vy, vrect|
      rx, ry = vx - @ox, vy - @oy
      sx, sy, sw, sh = @src_rect.as_ary

      tr, tg, tb, ta = @tone.as_ary
      ta = 255 if tr == 0 and tg == 0 and tb == 0

      # cropping
      dx = vrect.x - rx
      dy = vrect.y - ry
      dw = (rx + sw) - (vrect.x + vrect.width)
      dh = (ry + sh) - (vrect.y + vrect.height)

      (rx += dx; sx += dx; sw -= dx) if dx > 0
      (ry += dy; sy += dy; sh -= dy) if dy > 0
      sw -= dw if dw > 0
      sh -= dh if dh > 0

      texture.render_texture(
        @bitmap.texture, rx, ry,
        center_x: @ox, center_y: @oy,
        src_x: sx, src_y: sy, src_width: sw, src_height: sh,
        alpha: @opacity,
        blend_type: STARRUBY_BLEND_TYPE[@blend_type],
        scale_x: @zoom_x, scale_y: @zoom_y,
        angle: @angle / 180.0 * Math::PI,
        tone_red: tr, tone_green: tg, tone_blue: tb, saturation: ta
      )
    end
  end

  def initialize(viewport = nil)
    @viewport = viewport
    @bitmap   = nil
    @src_rect = nil
    @disposed = false

    @visible = true
    @opacity = 255

    @x, @y, @z = 0, 0, 0
    @ox, @oy   = 0, 0
    @zoom_x, @zoom_y = 1.0, 1.0
    @angle = 0

    @color = Color.new(0, 0, 0, 0)
    @tone = Tone.new(0, 0, 0, 0)

    @blend_type = 0

    register_drawable
    setup_iz_id
  end

  # IDisposable#dispose
  def dispose
    unregister_drawable
    super
  end

  ##
  # flash(Color color, int duration)
  #
  def flash(color, duration)
    return false
  end

  def update
    #update_flash
  end

  def width
    @src_rect ? @src_rect.width : 0
  end

  def height
    @src_rect ? @src_rect.height : 0
  end

  # PROPERTIES
  attr_reader :x, :y, :z, :ox, :oy, :zoom_x, :zoom_y,
              :bitmap, :src_rect, :viewport,
              :angle, :bush_depth, :blend_type,
              :bush_opacity, :opacity,
              :wave_amp, :wave_speed, :wave_phase, :wave_length,
              :mirror, :color, :tone,
              :visible

  ##
  # bitmap=(Bitmap bmp)
  #
  def bitmap=(bmp)
    @bitmap = bmp
    @src_rect ||= bmp ? bmp.rect : nil
    return @bitmap
  end

  def src_rect=(srect)
    #raise(ArgumentError, "expected Rect but received #{srect.class}") unless srect.kind_of?(Rect)
    @src_rect = srect
    if @bitmap
      @src_rect ||= @bitmap.rect.dup # In case the rect was set to nil and the bitmap is still valid
    end
    return @src_rect
  end

  def viewport=(view)
    @viewport = view
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

  def angle=(new_angle)
    @angle = new_angle.to_i
  end

  def wave_amp=(new_wave_amp)
    @wave_amp = new_wave_amp.to_i
  end

  def wave_amp=(new_wave_length)
    @wave_length = new_wave_length.to_i
  end

  def wave_speed=(new_wave_speed)
    @wave_speed = new_wave_speed.to_i
  end

  def wave_phase=(new_wave_phase)
    @wave_phase = new_wave_phase.to_i
  end

  def mirror=(new_mirror)
    @mirror = !!new_mirror
  end

  def bush_depth=(new_bush_depth)
    @bush_depth = new_bush_depth.to_i
  end

  def bush_opacity=(new_bush_opacity)
    @bush_opacity = new_bush_opacity.to_i
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
