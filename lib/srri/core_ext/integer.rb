class Integer
  def flag?(val)
    (self & val) == val
  end
end
