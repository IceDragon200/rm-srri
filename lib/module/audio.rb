#
# src/module/audio.rb
#
# vr 0.20
module Audio
class << self

  def init
    # nothing here but us chickens
  end

  def setup_midi
    #
  end

  def se_play(filename, volume=100, pitch=100)
    try_rtp_path(filename) do |fn|
      StarRuby::Audio.play_se(fn, volume: volume)
    end
  end

  def se_stop
    StarRuby::Audio.stop_all_ses
  end

  def bgm_play(filename, volume=100, pitch=100, pos=0)
    try_rtp_path(filename) do |fn|
      StarRuby::Audio.play_bgm(fn, volume: volume, time: pos, loop: true)
    end
  end

  def bgm_stop
    StarRuby::Audio.stop_bgm
  end

  def bgm_pos
    StarRuby::Audio.bgm_position
  end

  def bgm_fade(time)
  end

  def bgs_play(filename, volume=100, pitch=100, pos=0)
  end

  def bgs_stop
  end

  def bgs_pos
    0
  end

  def bgs_fade(time)
  end

  def me_play(filename, volume=100, pitch=100)
  end

  def me_stop
  end

  def me_fade(time)
  end

end
end

require_relative 'audio/base.rb'
require_relative 'audio/se.rb'
require_relative 'audio/bgm.rb'
