#
# rm-srri/lib-exp/texture-crossover.rb
#   dm 27/03/2013
# vr 1.0.1
class StarRuby::Texture

  ##
  # clear_rect(int x, int y, int w, int h)
  def clear_rect(x, y, w, h)
    fill_rect(x, y, w, h, StarRuby::Color::COLOR_TRANS)
  end

  def crop(x, y, w, h)
    dst_texture = StarRuby::Texture.new(w, h)
    dst_texture.render_texture(self, 0, 0, src_x: x, src_y: y,
                                           src_width: w, src_height: h,
                                           blend_type: :alpha)
    return dst_texture
  end

end
