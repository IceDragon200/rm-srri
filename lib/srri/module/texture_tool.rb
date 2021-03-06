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
    texture.render_texture(src_texture, sx, 0, src_width: sw)
    texture.render_texture(src_texture, 0, 0, src_x: sw, src_width: sx)
  end

  def self.offset_texture_y(texture, offset)
    offset = offset % texture.height
    return if offset == 0
    src_texture = texture.dup
    texture.clear
    sh = (texture.height - offset) % texture.height
    sy = texture.height - sh
    texture.render_texture(src_texture, 0, sy, src_height: sh)
    texture.render_texture(src_texture, 0, 0, src_y: sh, src_height: sy)
  end

  def self.loop_texture(texture, trg_rect, src_texture, src_rect)
    vx, vy = trg_rect.x, trg_rect.y
    sx, sy, w, h = src_rect.to_a

    xloop, xrem = trg_rect.width.divmod(w)
    yloop, yrem = trg_rect.height.divmod(h)

    for dy in 0...yloop
      for dx in 0...xloop
        texture.render_texture(src_texture, vx + (dx * w), vy + (dy * h),
                               src_x: sx, src_y: sy, src_width: w, src_height: h,
                               blend_type: StarRuby::Texture::BLEND_ALPHA)
      end
    end

    if xrem > 0
      for dy in 0...yloop
        texture.render_texture(src_texture, vx + (xloop * w), vy + (dy * h),
                               src_x: sx, src_y: sy, src_width: xrem, src_height: h,
                               blend_type: StarRuby::Texture::BLEND_ALPHA)
      end
    end

    if yrem > 0
      for dx in 0...xloop
        texture.render_texture(src_texture, vx + (dx * w), vy + (yloop * h),
                               src_x: sx, src_y: sy, src_width: w, src_height: yrem,
                               blend_type: StarRuby::Texture::BLEND_ALPHA)
      end
    end

    # End Tail
    if xrem > 0 && yrem > 0
      texture.render_texture(src_texture, vx + (xloop * w), vy + (yloop * h),
                             src_x: sx, src_y: sy, src_width: xrem, src_height: yrem,
                             blend_type: StarRuby::Texture::BLEND_ALPHA)
    end
    return true
  end

end