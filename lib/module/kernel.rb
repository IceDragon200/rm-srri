module Kernel

  def load_data(filename)
    obj = nil
    File.open(filename, "rb") do |f| obj = Marshal.load(f) end
    obj
  end unless method_defined? :load_data

  def save_data(obj, filename)
    File.open(filename, "wb") do |f| Marshal.dump(obj, f) end; self
  end unless method_defined? :save_data

  def msgbox(*args)
    return nil
  end

  def msgbox_p(*args)
    return nil
  end

end
