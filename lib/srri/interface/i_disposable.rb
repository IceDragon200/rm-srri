#
# rm-srri/lib/interface/i_disposable.rb
#   by IceDragon
#   dc ??/??/2012
#   dm 29/03/2013
# vr 1.0.1
module SRRI
  module Interface
    module IDisposable
      def disposed?
        !!@_disposed
      end

      def check_disposed
        raise(SRRI::Error.mk_dispose_error(self)) if disposed?
      end

      def dispose
        check_disposed
        @_disposed = true
      end
    end
  end
end
