#
# rm-srri/lib-exp/texture-crossover.rb
# vr 1.0.0
require File.join(File.dirname(__FILE__), 'color-addons')
class StarRuby::Texture

  ##
  # clear_rect(int x, int y, int w, int h)
  def clear_rect(x, y, w, h)
    fill_rect(x, y, w, h, StarRuby::Color::COLOR_TRANS)
  end

end
