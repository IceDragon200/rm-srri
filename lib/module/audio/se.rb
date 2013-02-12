module RGX::Audio

  class SE < RGX::Audio::Base

    def play
      Audio.se_play(@filename, @volume, @pitch)
    end

  end

end
