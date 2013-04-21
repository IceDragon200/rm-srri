#
# rm-srri/lib/interface/idisposable.rb
#   by IceDragon
#   dc ??/??/2012
#   dm 29/03/2013
# vr 1.0.1
module SRRI
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
end
