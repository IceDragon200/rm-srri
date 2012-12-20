##
# module TextureTool
#
module TextureTool

  def self.offset_texture_x(texture, offset)
    offset = offset % texture.width
    return if offset == 0
    src_texture = texture.dup
    texture.clear
    sw = (texture.width - offset) % texture.width
    sx = texture.width - sw
    texture.render_texture(
      src_texture, sx, 0, src_width: sw
    )
    texture.render_texture(
      src_texture, 0, 0, src_x: sw, src_width: sx
    )
  end

  def self.offset_texture_y(texture, offset)
    offset = offset % texture.height
    return if offset == 0
    src_texture = texture.dup
    texture.clear
    sh = (texture.height - offset) % texture.height
    sy = texture.height - sh
    texture.render_texture(
      src_texture, 0, sy, src_height: sh
    )
    texture.render_texture(
      src_texture, 0, 0, src_y: sh, src_height: sy
    )
  end

  def self.loop_texture(texture, trg_rect, bs_texture, src_rect, ox=0, oy=0, ext_properties={})

    src_texture = bs_texture.dup #Texture.new(src_rect.width, src_rect.height)
    offset_texture_x(src_texture, ox) if ox != 0
    offset_texture_y(src_texture, oy) if oy != 0

    vx, vy = trg_rect.x, trg_rect.y
    sx, sy, w, h = src_rect.as_ary

    xloop, xrem = trg_rect.width.divmod(w)
    yloop, yrem = trg_rect.height.divmod(h)

    full_rect = {
      src_x: sx, src_y: sy,
      src_width: w, src_height: h
    }.merge(ext_properties)

    properties = {
      src_x: sx, src_y: sy,
      src_width: xrem, src_height: yrem
    }.merge(ext_properties)

    yproperties = {
      src_x: sx, src_y: sy,
      src_width: xrem, src_height: h
    }.merge(ext_properties)

    xproperties = {
      src_x: sx, src_y: sy,
      src_width: w, src_height: yrem
    }.merge(ext_properties)

    for dy in 0...yloop
      for dx in 0...xloop
        texture.render_texture(
          src_texture, vx + (dx * w), vy + (dy * h), full_rect)
      end
    end

    if xrem > 0
      for dy in 0...yloop
        texture.render_texture(
          src_texture, vx + (xloop * w), vy + (dy * h), yproperties)
      end
    end

    if yrem > 0
      for dx in 0...xloop
        texture.render_texture(
          src_texture, vx + (dx * w), vy + (yloop * h), xproperties)
      end
    end

    # End Tail
    texture.render_texture(
      src_texture, vx + (xloop * w), vy + (yloop * h), properties
    ) if xrem > 0 && yrem > 0

    src_texture.dispose

    return true
  end

end
