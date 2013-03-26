module SRRI::Audio

  class SE < SRRI::Audio::Base

    def play
      Audio.se_play(@filename, @volume, @pitch)
    end

  end

end
