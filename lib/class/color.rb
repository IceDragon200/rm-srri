#
# rm-srri/lib/class/color.rb
# vr 1.0.1
SRRI::Color = StarRuby::Color

class SRRI::Color

  COLOR_TRANS = new(0, 0, 0, 0).freeze
  COLOR_BLACK = new(0, 0, 0, 255).freeze
  COLOR_WHITE = new(255, 255, 255, 255).freeze

end
