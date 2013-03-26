module SRRI::Audio

  class BGM < SRRI::Audio::Base

    def self.stop
    end

    def replay
      play(@pos)
    end

    def play(pos=0)
      return BGM.stop
      Audio.bgm_play(@filename, @volume, @pitch, pos)
    end

    def stop
      @pos = RPG::BGM.pos
      @@last = self
      Audio.bgm_stop
    end

  end

end
