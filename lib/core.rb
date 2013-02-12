def try_rtp_path(filename)
  ex = nil
  begin
    yield filename
  rescue Errno::ENOENT => ex
    yield File.join($rtp_path, filename)
  end
rescue Errno::ENOENT
  raise ex
end

def rgss_main
  Game.mk_starruby
  Graphics.init
  Audio.init
  Input.init

  begin
    yield
  rescue RGSSReset
    Graphics._reset
    retry
  end
end

def rgss_stop
  loop { Graphics.update }
end
