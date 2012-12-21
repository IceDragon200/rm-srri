#
# ext-so/table.rb
#
# vr 1.20
class RGX::Table

  def dup
    Marshal.load(Marshal.dump(self))
  end

  alias :clone :dup

end
