#
# src/class/viewport.rb
# vr 1.01
class RGX::Viewport

  include Interface::IDisposable
  include Interface::IZSortable

  def translate(x, y)
    yield x + @rect.x - @ox, y + @rect.y - @oy, @rect.clone
  end

  alias :rgx_vwp_initialize :initialize
  def initialize(*args, &block)
    rgx_vwp_initialize(*args, &block)
    setup_iz_id
  end

  def z=(new_z)
    @z = new_z.to_i
    super(@z)
  end

end
