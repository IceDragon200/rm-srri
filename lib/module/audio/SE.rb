module SRRI
module Audio

  class SE < SRRI::Audio::Base

    def play
      Audio.se_play(@filename, @volume, @pitch)
    end

  end

end
end
