#
# rm-srri/lib/class/sprite.rb
#
# vr 0.7.6

##
# class Sprite
#
# Currently Available
#   opacity (using alpha blend mode only)
#   blend_type
#   src_rect
#
class SRRI::Sprite

  include SRRI::Interface::IViewport

  STARRUBY_BLEND_TYPE = [
    # RGSS
    :alpha,    # 0
    :add,      # 1
    :sub,      # 2

    # StarRuby
    :mask,     # 3
    :mulitply, # 4
    #:divide,   # 5
    :none      # -1
  ]

  BLEND_ALPHA    = 0
  BLEND_ADD      = 1
  BLEND_SUBTRACT = 2
  BLEND_MASK     = 3
  BLEND_MULTIPLY = 4
  BLEND_NONE     = 5

  #-// old cropping code
  # Patch for Zoomed sprites
  #sw = Integer(sw * @zoom_x)
  #sh = Integer(sh * @zoom_y)

  # cropping
  #dx = vrect.x - rx
  #dy = vrect.y - ry
  #dw = (rx + sw) - (vrect.x + vrect.width)
  #dh = (ry + sh) - (vrect.y + vrect.height)

  #(rx += dx; sx += dx; sw -= dx) if dx > 0
  #(ry += dy; sy += dy; sh -= dy) if dy > 0
  #sw -= dw if dw > 0
  #sh -= dh if dh > 0

  def draw(texture)
    return false if @_disposed
    return false unless @visible
    return false unless @opacity > 0
    return false unless @zoom_x > 0
    return false unless @zoom_y > 0
    return false unless @src_rect
    return false unless @_texture
    return false if @viewport && !@viewport.visible
    return false if @_texture.disposed?
    return false if @src_rect.empty?

    (@viewport || Graphics).translate(@x, @y) do |vx, vy, vrect|
      rx, ry = vx - @ox, vy - @oy
      sx, sy, sw, sh = *@src_rect.to_a

      if @viewport
        sw *= @zoom_x if @zoom_x > 1.0
        sh *= @zoom_y if @zoom_y > 1.0

        # real view x, y, x2, y2
        rvx, rvy = vrect.x, vrect.y
        rvx2, rvy2 = rvx + vrect.width, rvy + vrect.height

        diffx = rx - rvx
        diffy = ry - rvy

        if diffx < 0
          unless @_ignore_viewport_crop
            sx -= diffx
            sw += diffx
          end
          rx -= diffx
        end

        if diffy < 0
          unless @_ignore_viewport_crop
            sy -= diffy
            sh += diffy
          end
          ry -= diffy
        end

        unless @_ignore_viewport_crop
          sw += [(rvx2 - (rx + sw)), 0].min
          sh += [(rvy2 - (ry + sh)), 0].min

          if @zoom_x > 1.0
            sw = (sw / @zoom_x).round
            rx += @src_rect.width / @zoom_x
          elsif @zoom_x < 1.0
            #rx -= sw * @zoom_x
          end

          if @zoom_y > 1.0
            sh = (sh / @zoom_y).round
            ry += @src_rect.height / @zoom_y
          elsif @zoom_y < 1.0
            #ry -= sh * @zoom_y
          end
        end
      end

      texture.render_texture(
        @_texture, rx, ry,
        center_x: @ox, center_y: @oy,
        src_x: sx, src_y: sy, src_width: sw, src_height: sh,
        alpha: @opacity, blend_type: STARRUBY_BLEND_TYPE[@blend_type],
        scale_x: @zoom_x, scale_y: @zoom_y,
        angle: @angle.degree_to_radian, tone: @tone, color: @color
      )
    end
  end

  # PROPERTIES
  attr_reader :x, :y, :z, :ox, :oy, :zoom_x, :zoom_y,
              :bitmap, :src_rect, :viewport,
              :angle, :bush_depth, :blend_type,
              :bush_opacity, :opacity,
              :wave_amp, :wave_speed, :wave_phase, :wave_length,
              :mirror, :color, :tone,
              :visible

  def initialize(viewport = nil)
    # external
    @viewport = viewport
    @bitmap   = nil

    @visible = true
    @opacity = 255

    @x, @y, @z = 0, 0, 0
    @ox, @oy   = 0, 0
    @zoom_x, @zoom_y = 1.0, 1.0
    @angle = 0

    @src_rect = SRRI::Rect.new(0, 0, 0, 0)

    @color = SRRI::Color.new(0, 0, 0, 0)
    @tone  = SRRI::Tone.new(0, 0, 0, 0)

    @blend_type = 0

    @_disposed = false

    @bush_depth   = 0
    @bush_opacity = 0

    @wave_amp    = 0
    @wave_speed  = 0
    @wave_phase  = 0
    @wave_length = 0

    @_ignore_viewport_crop = false

    register_drawable
    setup_iz_id
  end

  def dup
    raise(SRRI.mk_copy_error(self))
  end

  def clone
    raise(SRRI.mk_copy_error(self))
  end

  def dispose
    super
    @_texture = nil
  end

  def update
    # TODO
    #   flash effect
  end

  ##
  # flash(Color color, int duration)
  #
  def flash(color, duration)
    check_disposed
    return false
  end

  def width
    @src_rect.width
  end

  def height
    @src_rect.height
  end

  ##
  # bitmap=(Bitmap bmp)
  #
  def bitmap=(bmp)
    @bitmap = bmp
    @src_rect = @bitmap ? @bitmap.rect.dup : Rect.new(0, 0, 0, 0)
    @_texture = @bitmap ? @bitmap.texture : nil
  end

  def src_rect=(srect)
    @src_rect = srect || @bitmap ? @bitmap.rect.dup : nil
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
    @bush_opacity = [[new_bush_opacity.to_i, 0].max, 255].min
  end

  def opacity=(new_opacity)
    @opacity = [[new_opacity.to_i, 0].max, 255].min
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
