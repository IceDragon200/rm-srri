#
# src/module/audio.rb
#
# vr 0.2.1
module SRRI
  module Audio
    class << self
      AUDIO_EXTS = %w[.ogg .wav .mp3]

      def init
        # nothing here but us chickens
        SRRI.try_log do |logger|
          logger.puts("SRRI | Audio initialized")
        end
      end

      def setup_midi
        #
      end

      def se_play(filename, volume=100, pitch=100)
        SRRI.find_path(filename, AUDIO_EXTS) do |fn|
          StarRuby::Audio.play_se(fn, volume: volume)
        end
        return true
      end

      def se_stop
        StarRuby::Audio.stop_all_ses
        return true
      end

      def bgm_play(filename, volume=100, pitch=100, pos=0)
        SRRI.find_path(filename, AUDIO_EXTS) do |fn|
          StarRuby::Audio.play_bgm(fn, volume: volume, time: pos, loop: true)
        end
        return true
      end

      def bgm_stop
        StarRuby::Audio.stop_bgm
        return true
      end

      def bgm_pos
        StarRuby::Audio.bgm_position
        return true
      end

      def bgm_fade(time)
        return false
      end

      def bgs_play(filename, volume=100, pitch=100, pos=0)
        return false
      end

      def bgs_stop
        return false
      end

      def bgs_pos
        0
      end

      def bgs_fade(time)
        return false
      end

      def me_play(filename, volume=100, pitch=100)
        return false
      end

      def me_stop
        return false
      end

      def me_fade(time)
        return false
      end
    end
  end
end
