#
# ext-so/rect.rb
#
# vr 1.0
class RGX::Rect

  def to_s
    s = super
    s[0...(s.length-1)] + " [#{self.x}, #{self.y}, #{self.width}, #{self.height}]>"
  end

  def dup
    Marshal.load(Marshal.dump(self))
  end
  alias clone dup

end
