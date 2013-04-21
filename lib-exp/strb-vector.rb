#
# rm-srri/lib-exp/strb-vector.rb
#   by IceDragon
#   dc 03/04/2013
#   dm 03/04/2013
# vr 1.0.0
#   Vector Extension
#
class StarRuby::Vector

  def magnitude
    return Math.sqrt(self.x * self.x + self.y * self.y)
  end

  def magnitude=(new_magnitude)
    rad = radian
    self.x = new_magnitude * Math.cos(rad)
    self.y = new_magnitude * Math.sin(rad)
  end

  def radian
    Math.atan2(self.y, self.x)
  end

  def radian=(new_radian)
    mag = magnitude
    self.x = mag * Math.cos(new_radian)
    self.y = mag * Math.sin(new_radian)
  end

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

class StarRuby::Vector2I

  def zero?
    self.x == 0 && self.y == 0
  end

end

class StarRuby::Vector2F

  def zero?
    self.x == 0.0 && self.y == 0.0
  end

end

class StarRuby::Vector3I

  def zero?
    self.x == 0 && self.y == 0 && self.z == 0
  end

end

class StarRuby::Vector3F

  def zero?
    self.x == 0.0 && self.y == 0.0 && self.z == 0.0
  end

end
