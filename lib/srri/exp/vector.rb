#
# rm-srri/lib-exp/strb-vector.rb
#   by IceDragon
#   dc 03/04/2013
#   dm 03/04/2013
# vr 1.0.0
#   Vector Extension
#
class StarRuby::Vector
  def normalize!
    rad = radian
    self.x = Math.cos(rad)
    self.y = Math.sin(rad)
    self
  end unless method_defined?(:normalize!)

  def normalize
    return dup.normalize!
  end unless method_defined?(:normalize)

  def polar
    [magnitude, radian]
  end unless method_defined?(:polar)

  def flipflop!
    self.x, self.y = self.y, self.x
    self
  end unless method_defined?(:flipflop!)

  def flipflop
    dup.flipflop!
  end unless method_defined?(:flipflop)
end
