def try_rtp_path(filename)
  yield filename
rescue Errno::ENOENT
  yield File.join($rtp_path, filename)
end

def rgss_main(&block)
  Game.mk_starruby
  SRRI.init
  begin
    block.call
  rescue RGSSReset
    puts 'reset'
    Graphics._reset
    retry
  end
end

def rgss_stop
  loop { Graphics.update }
end

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
