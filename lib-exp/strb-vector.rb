#
# rm-srri/lib-exp/strb-vector.rb
#   by IceDragon
#   dc 03/04/2013
#   dm 03/04/2013
# vr 1.0.0
#   Vector Extension
#
class StarRuby::Vector

  def angle
    return radian * PI180
  end

  def normalize!
    rad = radian
    self.x = Math.cos(rad)
    self.y = Math.sin(rad)
    self
  end

  def normalize
    return dup.normalize!
  end

  def polar
    [magnitude, radian]
  end

  def flipflop!
    self.x, self.y = self.y, self.x
    self
  end

  def flipflop
    dup.flipflop!
  end

end
