#
# rm-srri/lib/srri.rb
# vr 2.0.0
module SRRI

  class CopyError < RuntimeError
  end

  VERSION = "2.0.0".freeze

  def self.mk_copy_error(obj)
    return CopyError.new("Cannot copy #{obj}")
  end

end

require 'starruby/local.rb'

%w(interfaces classes modules patches exposure).each do |fn|
  require File.join(File.dirname(__FILE__), fn)
end

module SRRI

  Font.init

  DEFAULT_WIDTH  = 544
  DEFAULT_HEIGHT = 416

  @@rtp_path = "/home/icy/Dropbox/xdev/RMVXA-RTP/"
  @@config = {
    cursor: false,
    frame_rate: 60,
    title: "Game",
    fullscreen: false,
    vsync: false
  }

  def self.rtp_path
    return @@rtp_path
  end

  def self.try_rtp_path(filename)
    ex = nil
    if !Dir.glob(filename + "*").empty?
      yield filename
    else
      yield File.join(rtp_path, filename)
    end
  end

  def self.mk_starruby()
    Graphics.starruby.close_window if Graphics.starruby
    game = StarRuby::Game.new(
      Graphics.width,
      Graphics.height,
      cursor:     @@config[:cursor],
      fps:        @@config[:frame_rate],
      title:      @@config[:title],
      fullscreen: @@config[:fullscreen],
      vsync: @@config[:vsync]
    )

    Graphics.starruby = game
  end

end

def rgss_main
  SRRI.mk_starruby
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
