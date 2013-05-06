#
# rm-srri/lib/interface/idisposable.rb
#   by IceDragon
#   dc ??/??/2012
#   dm 29/03/2013
# vr 1.0.1
module SRRI
module Interface
module IDisposable

  def check_disposed
    raise(SRRI.mk_dispose_error(self)) if disposed?
  end

  def dispose
    check_disposed
    @_disposed = true
  end

  def disposed?
    !!@_disposed
  end

end
end
end
