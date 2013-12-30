module SRRI
  module Audio

    class Base

      attr_accessor :filename, :volume, :pitch

      def initialize(filename, vol=100, pitch=100)
        @filename, @volume, @pitch = filename, vol, pitch
      end

      def play
        raise("#{self.class}#play is invalid!")
      end

    end

  end
end
