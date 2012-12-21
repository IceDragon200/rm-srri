class RGX::Tone

  def to_s
    "<#{self.class.name} {red: #{red} green: #{green} blue: #{blue} grey: #{grey}}>"
  end

  # Because I have spelling fails
  alias :gray :grey
  alias :gray= :grey=

end
