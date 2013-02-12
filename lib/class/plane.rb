#
# src/class/plane.rb
#
# vr 0.83

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

      tr, tg, tb, ta = @tone.as_ary
      ta = 255 if tr == 0 and tg == 0 and tb == 0

      return if vw <= 0 || vh <= 0

      tw = ((vw / src_texture.width).ceil + 2) * src_texture.width
      th = ((vh / src_texture.height).ceil + 2) * src_texture.height

      @_texture_changed |= (!@_texture ||
        @_texture.width != tw || @_texture.height != th)

      if @_texture_changed

        @_texture.dispose if @_texture and !@_texture.disposed?

        @_texture = StarRuby::Texture.new(tw, th)

        TextureTool.loop_texture(
          @_texture, RGX::Rect.new(0, 0, tw, th),
          src_texture, src_texture.rect
        )

        @_texture_changed = false
      end

      texture.render_texture(
        @_texture, rx, ry,
        src_x: @ox % src_texture.width, src_y: @oy % src_texture.height,
        src_width: vw, src_height: vh,
        alpha: @opacity,
        blend_type: Sprite::STARRUBY_BLEND_TYPE[@blend_type],
        scale_x: @zoom_x, scale_y: @zoom_y,
        tone_red: tr, tone_green: tg, tone_blue: tb, saturation: ta
      )

    end
  end

  alias :rgx_pln_initialize :initialize
  def initialize(*args, &block)
    @_texture = nil
    @_last_ox, @_last_oy = 0, 0
    @_texture_changed = true

    rgx_pln_initialize(*args, &block)

    register_drawable
    setup_iz_id
  end

  def dispose
    @_texture.dispose if @_texture and not @_texture.disposed?
    unregister_drawable
    super
  end

  alias :rgx_plan_bitmap_set :bitmap=
  def bitmap=(new_bitmap)
    rgx_plan_bitmap_set(new_bitmap)
    @_texture_changed = true
  end

  def viewport=(new_viewport)
    @viewport = new_viewport
    @_texture_changed = true
    super(@viewport)
  end

  def z=(new_z)
    @z = new_z.to_i
    super(@z)
  end

end
