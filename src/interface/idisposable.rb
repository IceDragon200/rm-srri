#
# src/interface/idisposable.rb
#
module Interface
  module IDisposable

    def dispose
      @disposed = true
    end

    def disposed?
      !!@disposed
    end

  end
end
