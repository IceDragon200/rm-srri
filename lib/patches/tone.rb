#
# rm-srri/lib/patches/tone.rb
#
__END__

class SRRI::Tone

class << self
  alias :org_new :new
  def new(*args)
    obj = org_new(*args)
    obj.saturation = obj.gray
    return obj
  end
end

  alias :org_initialize :initialize
  def initialize(*args)
    obj = org_initialize(*args)
    obj.saturation = obj.gray
    return obj
  end

  alias :org_set :set
  def set(*args)
    obj = org_set(*args)
    obj.saturation = obj.gray
    return obj
  end

end
