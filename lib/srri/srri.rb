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
    filename = File.join(File.dirname(filename), File.basename(filename, File.extname(filename)))
    org_filename = filename.dup
    filename = File.expand_path(filename)
    result = nil
    if n = Dir.glob(filename + ".*").first
      result = n
    else
      pth = File.join(rtp_path, org_filename)
      if n = Dir.glob(pth + ".*").first
        result = n
      else
        raise(Errno::ENOENT, org_filename)
      end
    end
    #raise(Errno::ENOENT, org_filename) unless result
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
      fps:        Graphics.frame_rate,
      title:      @@config[:title],
      fullscreen: @@config[:fullscreen],
      vsync:      @@config[:vsync]
    )
    Graphics.starruby = @@current_game
    Input.starruby    = @@current_game
    return @@current_game
  end

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
      y = (anchor >> 4) & 0xF
      [(x == 0 ? 0.0 : (x == 1 ? -1.0 : (x == 2 ? 0.5 :  1.0))),
       (y == 0 ? 0.0 : (y == 1 ?  1.0 : (y == 2 ? 0.5 : -1.0)))]
    else
      raise(ArgumentError, "unsupported anchor %d" % anchor)
      #if anchor
        #v = MACL::Surface::Tool.anchor_to_vec2(anchor)
      #end
    end
  end

end

require 'starruby/local.rb'

%w(interfaces classes modules patches exposure).each do |fn|
  require File.join(File.dirname(__FILE__), fn)
end

module SRRI

  Font.init

  COLOR_TRANS = Color.new(0, 0, 0, 0).freeze

  DEFAULT_WIDTH  = 544
  DEFAULT_HEIGHT = 416

  @@rtp_path = File.join(ENV['HOME'].gsub(/\\/, '/'),
                         'Enterbrain', 'RGSS3', 'RPGVXAce')

  @@config = {
    cursor: false,
    title: "Game",
    fullscreen: false,
    vsync: false
  }

  @@flash_cache = {}

  @@current_game = nil

end

include SRRI::SRKernel