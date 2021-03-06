module SRRI
  module Audio

    class BGM < SRRI::Audio::Base

      def self.stop
      end

      def replay
        play(@pos)
      end

      def play(pos=0)
        BGM.stop
        Audio.bgm_play(@filename, @volume, @pitch, pos)
      end

      def stop
        @pos = StarRuby::Audio.bgm_pos
        @@last = self
        Audio.bgm_stop
      end

    end

  end
end
