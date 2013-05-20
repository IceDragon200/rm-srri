#
# rm-srri/lib/srri.rb
#   dm 09/05/2013
module SRRI

  VERSION = "0.8.3".freeze

  ##
  # Constants
  BIT = (Array.new(64) { |i| i > 0 ? 2 ** (i - 1) : 0 }).freeze

module Error

  class DisposeError < RuntimeError
  end

  class ExposureError < RuntimeError
  end

  class CopyError < RuntimeError
  end

  def self.mk_copy_error(obj)
    CopyError.new("cannot copy %s" % obj.class.name)
  end

  def self.mk_dispose_error(obj)
    DisposeError.new("cannot modify disposed %s" % obj.class.name)
  end

  def self.mk_exposure_error(msg)
    ExposureError.new(msg)
  end

end

module Interrupts

  class SRRIBreak < Interrupt
  end

end

  def self.log=(new_log)
    @log = new_log
  end

  def self.log
    @log
  end

  def self.try_log
    yield(@log) if @log
  end

end

require 'starruby/local.rb'

%w(interfaces classes modules patches exposure).each do |fn|
  require File.join(File.dirname(__FILE__), fn)
end

module SRRI

  COLOR_TRANS = Color.new(0, 0, 0, 0).freeze

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
    raise(SRRI::Interrupts::SRRIBreak)
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

  @@flash_cache = {}

  def self.rgb12_color(rgb12)
    (@@flash_cache[rgb12] ||= Color.new(((rgb12 >> 8) & 0xF) * 0x11,
                                        ((rgb12 >> 4) & 0xF) * 0x11,
                                        ((rgb12 >> 0) & 0xF) * 0x11))
  end

  ## 0.8.2
  # ::viewport_clip
  def self.viewport_clip(rect, x, y, w, h)
    if x < rect.x
      w -= rect.x - x
      x = rect.x
    end
    if y < rect.y
      h -= rect.y - y
      y = rect.y
    end
    if (x2 = x + w) > (rx2 = rect.x + rect.width)
      w -= x2 - rx2
    end
    if (y2 = y + h) > (ry2 = rect.y + rect.height)
      h -= y2 - ry2
    end
    return x, y, w, h
  end

  def self.cast_anchor(anchor)
    if anchor < 10
      anchor =case anchor
              when 0 then 0x200
              when 1 then 0x211
              when 2 then 0x212
              when 3 then 0x213
              when 4 then 0x221
              when 5 then 0x222
              when 6 then 0x223
              when 7 then 0x231
              when 8 then 0x232
              when 9 then 0x233
              end
    end
    anchor
  end

  def self.anchor_to_v2f_a(anchor)
    if anchor >= 0x3000
      raise(ArgumentError, "3D anchors are not supported")
    elsif anchor >= 0x200
      x = (anchor >> 0) & 0xF
      y = (anchor >> 8) & 0xF
      [(x == 0 ? 0.0 : (x == 1 ? -1.0 : (x == 2 ? 0.5 : 1.0))),
       (y == 0 ? 0.0 : (y == 1 ? -1.0 : (y == 2 ? 0.5 : 1.0)))]
    else
      raise(ArgumentError, "unsupported anchor %d" % anchor)
      #if anchor
        #v = MACL::Surface::Tool.anchor_to_vec2(anchor)
      #end
    end
  end

  Font.init

end

def rgss_main
  SRRI.mk_starruby
  SRRI::Graphics.init
  SRRI::Audio.init
  SRRI::Input.init

  begin
    yield
  rescue SRRI::RGSSReset
    SRRI.try_log { |logger| logger.puts("Reset Signal received") }
    Graphics._reset
    retry
  rescue SRRI::Interrupts::SRRIBreak
    SRRI.try_log { |logger| logger.puts("Break Signal received") }
  end
end

def rgss_stop
  loop { Graphics.update }
end
