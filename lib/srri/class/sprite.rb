#
# rm-srri/lib/class/Sprite.rb
#   by IceDragon
#   dc ??/??/2012
#   dm 09/05/2013
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

  include SRRI::Interface::IRenderable
  include SRRI::Interface::IZOrder

  register_renderable('Sprite')

  STARRUBY_BLEND_TYPE = [
    # RGSS
    :alpha,    # 0
    :add,      # 1
    :sub,      # 2

    # StarRuby
    :src_mask, # 3
    :dst_mask, # 3
    :mulitply, # 4
    :divide,   # 5
    :none      # -1
  ]

  BLEND_TYPE_ALPHA    = 0 #StarRuby::Texture::BLEND_TYPE_ALPHA
  BLEND_TYPE_ADD      = 1 #StarRuby::Texture::BLEND_TYPE_ADD
  BLEND_TYPE_SUBTRACT = 2 #StarRuby::Texture::BLEND_TYPE_SUBTRACT
  BLEND_TYPE_SRC_MASK = 3 #StarRuby::Texture::BLEND_TYPE_SRC_MASK
  BLEND_TYPE_DST_MASK = 4 #StarRuby::Texture::BLEND_TYPE_DST_MASK
  BLEND_TYPE_MULTIPLY = 5 #StarRuby::Texture::BLEND_TYPE_MULTIPLY
  BLEND_TYPE_NONE     = 6 #StarRuby::Texture::BLEND_TYPE_NONE

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

  ## SRRI
  # post_render(Texture texture, Integer x, Integer y)
  #   Post Rendering callback
  def post_render(texture, x=nil, y=nil)
    #
  end

  ## SRRI::Interface::IDrawable
  # render(Texture texture)
  def render(texture)
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

    old_clip = texture.clip_rect

    (@viewport || Graphics).translate(@x, @y) do |x, y, vrect|
      rx, ry = x - @ox, y - @oy
      texture.clip_rect = vrect
      if @_flash_color
        r = (@_flash_duration.to_f / @_flash_duration_max)
        color = @color.dup
        color.red   = color.red   + (@_flash_color.red   * r)
        color.blue  = color.blue  + (@_flash_color.blue  * r)
        color.green = color.green + (@_flash_color.green * r)
      else
        color = @color
      end
      texture.render_texture(
        @_texture, rx, ry,
        center_x: @ox, center_y: @oy,
        src_rect: @src_rect,
        #src_x: sx, src_y: sy, src_width: sw, src_height: sh,
        alpha: @opacity, blend_type: STARRUBY_BLEND_TYPE[@blend_type],
        scale_x: @zoom_x, scale_y: @zoom_y,
        angle: @angle.to_radian, tone: @tone, color: color
      )
      post_render(texture, rx, ry)
    end

    texture.clip_rect = old_clip
  end

  @@sprite_id = 0

  # PROPERTIES
  attr_reader :id
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

    setup_iz_id
    register_renderable

    @id = @@sprite_id
    @@sprite_id += 1
  end

  def dup
    raise(SRRI::Error.mk_copy_error(self))
  end

  def clone
    raise(SRRI::Error.mk_copy_error(self))
  end

  def dispose
    super
    @_texture = nil
  end

  def update
    if @_flash_color
      @_flash_duration -= 1
      if @_flash_duration < 0
        @_flash_color = nil
        @_flash_duration = nil
        @_flash_duration_max = nil
        #@_flash_tone = nil
      end
    end
  end

  ##
  # flash(Color color, int duration)
  #
  def flash(color, duration)
    check_disposed
    @_flash_color = color
    @_flash_duration = @_flash_duration_max = duration

    ## due to technical limitations, color is used as a Tone instead
    #@_flash_tone = @_flash_color.to_tone

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

  # Handled by Interface::IZOrder
  #def z=(new_z)
  #  @z = new_z.to_i
  #  super(@z)
  #end

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

  def wave_length=(new_wave_length)
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