#
# rm-srri/lib-exp/texture-crossover.rb
#   dm 27/03/2013
# vr 1.0.1
class StarRuby::Texture

  ## depreceated
  # clear_rect(Integer x, Integer y, Integer w, Integer h)
  def clear_rect(x, y, w, h)
    fill_rect(x, y, w, h, StarRuby::Color::COLOR_TRANS)
  end unless method_defined?(:clear_rect)

  ## depreceated
  # crop(Integer x, Integer y, Integer w, Integer h)
  def crop(x, y, w, h)
    dst_texture = StarRuby::Texture.new(w, h)
    dst_texture.render_texture(self, 0, 0, src_x: x, src_y: y,
                                           src_width: w, src_height: h,
                                           blend_type: :alpha)
    return dst_texture
  end unless method_defined?(:crop)

  ##
  # clip
  def clip
    old_rect = self.clip_rect ? self.clip_rect.dup : nil
    yield(self.clip_rect ||= rect)
    self.clip_rect = old_rect
  end unless method_defined?(:clip)

  ##
  # render(Texture texture)
  def render(texture)
    texture.render_texture(self, 0, 0)
    return true
  end unless method_defined?(:render)

end