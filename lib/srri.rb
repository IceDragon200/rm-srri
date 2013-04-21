#
# rm-srri/lib/srri.rb
module SRRI

  class CopyError < RuntimeError
  end

  class SRRIBreak < Interrupt
  end

  VERSION = "0.7.1".freeze

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
  @@current_game = nil

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

  def self.dispose_starruby
    Graphics.starruby = nil
    Input.starruby    = nil
    @@current_game.dispose unless @@current_game.disposed?
    @@current_game = nil
  end

  def self.kill_starruby
    dispose_starruby
    raise(SRRI::SRRIBreak)
  end

  def self.mk_starruby
    dispose_starruby if @@current_game
    @@current_game = StarRuby::Game.new(
      Graphics.width,
      Graphics.height,
      cursor:     @@config[:cursor],
      fps:        @@config[:frame_rate],
      title:      @@config[:title],
      fullscreen: @@config[:fullscreen],
      vsync:      @@config[:vsync]
    )
    Graphics.starruby = @@current_game
    Input.starruby    = @@current_game
    return @@current_game
  end

end

def rgss_main
  SRRI.mk_starruby
  SRRI::Graphics.init
  SRRI::Audio.init
  SRRI::Input.init

  begin
    yield
  rescue SRRI::RGSSReset
    Graphics._reset
    retry
  rescue SRRI::SRRIBreak

  end
end

def rgss_stop
  loop { Graphics.update }
end
