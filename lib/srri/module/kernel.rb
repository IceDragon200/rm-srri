#
# rm-srri/lib/module/Kernel.rb
#   dm 26/05/2013
# vr 1.0.0
module Kernel

  ##
  # load_data(String filename)
  def load_data(filename)
    obj = nil
    File.open(filename, "rb") { |f| obj = Marshal.load(f) }
    obj
  end unless method_defined?(:load_data)

  ##
  # save_data(Object* obj, String filename)
  def save_data(obj, filename)
    File.open(filename, "wb") { |f| Marshal.dump(obj, f) }
  end unless method_defined?(:save_data)

  ##
  # msgbox(String filename)
  def msgbox(*args)
    puts args
    #return nil
  end unless method_defined?(:msgbox)

  ##
  # msgbox_p
  def msgbox_p(*args)
    p args
    #return nil
  end unless method_defined?(:msgbox_p)

end
