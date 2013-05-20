#
# rm-srri/lib/class/Plane.rb
#   by IceDragon
#   dc ??/??/2012
#   dm 09/05/2013
# vr 0.8.4

##
# class Plane
#
class SRRI::Plane

  include SRRI::Interface::IRenderable
  include SRRI::Interface::IZOrder

  register_renderable('Plane')

  def render(texture)
    return false unless @bitmap
    return false unless @visible
    return false if @opacity == 0
    return false if @viewport && !@viewport.visible

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

      return if vw <= 0 || vh <= 0

      tw = ((vw / src_texture.width).ceil + 2) * src_texture.width
      th = ((vh / src_texture.height).ceil + 2) * src_texture.height

      @_texture_changed |= (!@_texture ||
        @_texture.width != tw || @_texture.height != th)

      if @_texture_changed
        @_texture.dispose if @_texture and !@_texture.disposed?
        @_texture = StarRuby::Texture.new(tw, th)
        TextureTool.loop_texture(@_texture, Rect.new(0, 0, tw, th),
                                 src_texture, src_texture.rect)
        @_texture_changed = false
      end

      texture.render_texture(
        @_texture, rx, ry,
        src_x: @ox % src_texture.width, src_y: @oy % src_texture.height,
        src_width: vw, src_height: vh,
        alpha: @opacity,
        blend_type: Sprite::STARRUBY_BLEND_TYPE[@blend_type],
        scale_x: @zoom_x, scale_y: @zoom_y,
        tone: @tone, color: @color
      )

    end
  end

  attr_reader :z, :ox, :oy,
            :zoom_x, :zoom_y,
            :bitmap, :viewport,
            :visible, :opacity,
            :blend_type,
            :color, :tone

  def initialize(viewport=nil)
    @viewport = viewport
    @bitmap = nil
    @ox, @oy, @z = 0, 0, 0

    @opacity = 255

    @zoom_x, @zoom_y = 1.0, 1.0

    @visible = true

    @blend_type = 0

    @tone  = SRRI::Tone.new(0, 0, 0, 0)
    @color = SRRI::Color.new(0, 0, 0, 0)

    @_texture = nil
    @_last_ox, @_last_oy = 0, 0
    @_texture_changed = true

    setup_iz_id
    register_renderable
  end

  def dispose
    super
    @_texture.dispose if @_texture and not @_texture.disposed?
  end

  def bitmap=(new_bitmap)
    @bitmap = new_bitmap
    @_texture_changed = true
  end

  def viewport=(new_viewport)
    @_texture_changed = true
    super(@viewport)
  end

  def visible=(vis)
    @visible = !!vis
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
