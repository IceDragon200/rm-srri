#
# src/class/sprite.rb
#
# vr 0.74

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
    return false if @disposed
    return false unless @bitmap
    return false if @bitmap.disposed?
    return false unless @visible
    return false if @opacity == 0
    return false unless @src_rect
    return false if @src_rect.empty?
    return false if @zoom_x <= 0.0
    return false if @zoom_y <= 0.0
    return false if @viewport && !@viewport.visible

    (@viewport || Graphics).translate(@x, @y) do |vx, vy, vrect|
      rx, ry = vx - @ox, vy - @oy
      sx, sy, sw, sh = *@src_rect.as_ary
      tr, tg, tb, ta = *@tone.as_ary

      if @viewport
        sw *= @zoom_x if @zoom_x > 1.0
        sh *= @zoom_y if @zoom_y > 1.0

        #sx2, sy2 = sx + sw, sy + sh
        rx2 = rx + sw
        ry2 = ry + sh

        # real view x, y, x2, y2
        rvx, rvy = vrect.x, vrect.y
        rvx2, rvy2 = vrect.x + vrect.width, vrect.y + vrect.height

        diffx = rx - rvx
        diffy = ry - rvy
        diffx2 = rvx2 - rx2
        diffy2 = rvy2 - ry2

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
          sw += diffx2 if diffx2 < 0
          sh += diffy2 if diffy2 < 0

          if @zoom_x > 1.0
            sw = (sw / @zoom_x).round
            rx += @src_rect.width / @zoom_x
          elsif @zoom_x < 1.0
            #rx -= sw #* @zoom_x
          end

          if @zoom_y > 1.0
            sh = (sh / @zoom_y).round
            ry += @src_rect.height / @zoom_y
          elsif @zoom_y < 1.0
            #ry -= sh #* @zoom_y
          end
        end
      end

      blnd = STARRUBY_BLEND_TYPE[@blend_type]
      ang = @angle.to_radian

      texture.render_texture(
        @bitmap.texture, rx, ry,
        center_x: @ox, center_y: @oy,
        src_x: sx, src_y: sy, src_width: sw, src_height: sh,
        alpha: @opacity, blend_type: blnd,
        scale_x: @zoom_x, scale_y: @zoom_y,
        angle: ang,
        tone_red: tr, tone_green: tg, tone_blue: tb, saturation: 255 - ta
      )
    end
  end

  alias :rgx_sp_initialize :initialize
  def initialize(*args, &block)
    # internal

    # Until I can fix the viewport cropping for small zoomed objects
    @_ignore_viewport_crop = false

    rgx_sp_initialize(*args, &block)

    register_drawable
    setup_iz_id
  end

  # IDisposable#dispose
  def dispose
    unregister_drawable
    super
  end

  def viewport=(view)
    @viewport = view
    super(@viewport)
  end

  def z=(new_z)
    @z = new_z.to_i
    super(@z)
  end

end
