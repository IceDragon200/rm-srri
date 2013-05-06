#
# rm-srri/lib/srri.rb
module SRRI

  class DisposeError < RuntimeError
  end

  class ExposureError < RuntimeError
  end

  class CopyError < RuntimeError
  end

  class SRRIBreak < Interrupt
  end

  VERSION = "0.8.0".freeze

  def self.mk_copy_error(obj)
    CopyError.new("Cannot copy %s" % obj.class.name)
  end

  def self.mk_dispose_error(obj)
    DisposeError.new("cannot modify disposed %s" % obj.class.name)
  end

end

require 'starruby/local.rb'

%w(interfaces classes modules patches exposure).each do |fn|
  require File.join(File.dirname(__FILE__), fn)
end

module SRRI

  COLOR_TRANS = Color.new(0, 0, 0, 0).freeze

  Font.init

  DEFAULT_WIDTH  = 544
  DEFAULT_HEIGHT = 416

  @@rtp_path = File.join(ENV['HOME'].gsub(/\\/, '/'),
                         'Enterbrain', 'RGSS3', 'RPGVXAce')

  @@config = {
    cursor: false,
    frame_rate: 60,
    title: "Game",
    fullscreen: false,
    vsync: false
  }

  @@current_game = nil

  ##
  # ::rtp_path -> String
  def self.rtp_path
    return @@rtp_path
  end

  ##
  # ::remove_extension(String str)
  def self.remove_extension(str)
    File.join(File.dirname(str), File.basename(str, File.extname(str)))
  end

  ##
  # ::find_path(String filename) -> String
  def self.find_path(filename)
    strict_case = true
    org_filename = filename.dup
    result = nil
    if !Dir.glob(filename + "*").empty?
      result = filename
    else
      begin
        entries = Dir.entries(File.dirname(org_filename))
      rescue Errno::ENOENT
        entries = []
      end
      entries.delete('.'); entries.delete('..')
      entries.map! do |s|
        File.join(File.dirname(org_filename), s)
      end
      unless strict_case
        n = entries.find { |s| org_filename.casecmp(remove_extension(s)) == 0 }
      else
        n = false
      end
      if n
        result = n
      else
        pth = File.join(rtp_path, org_filename)
        if !Dir.glob(pth + "*").empty?
          result = pth
        else
          raise(Errno::ENOENT, org_filename)
        end
      end
    end
    yield result if block_given?
    return result
  end

  ##
  # dispose_starruby
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
