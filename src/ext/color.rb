class RGX::Color
class << self

  private :new4

  def new(*args)
    case args.size
    when 0
      r, g, b, a = 0, 0, 0, 255
    when 1
      c, = args
      raise(ArgumentError) unless c.kind_of?(Color)
      r, g, b, a = *c.as_ary
    when 3
      r, g, b = *args
      a = 255
    when 4
      r, g, b, a = *args
    end
    new4(r, g, b, a);
  end

end

  private :initialize4, :set4

  def initialize(*args)
    initialize4(*args)
  end

  def set(*args)
    case args.size
    when 1
      c, = args
      raise(ArgumentError) unless c.kind_of?(Color)
      r, g, b, a = *c.as_ary
    when 3
      r, g, b = *args
      a = self.alpha
    when 4
      r, g, b, a = *args
    end
    set4(r, g, b, a);
  end

  def to_s
    "<#{self.class.name} {red: #{red} green: #{green} blue: #{blue} alpha: #{alpha}}>"
  end

  def _dump(d = 0)
    [red, green, blue, alpha].pack('d4')
  end
   
  def self._load(s)
    self.new(*s.unpack('d4'))
  end

  def dup
    Marshal.load(Marshal.dump(self))
  end
  alias clone dup

end
