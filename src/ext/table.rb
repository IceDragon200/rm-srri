#
# ext-so/table.rb
#
# vr 1.1
class RGX::Table
  # Mostly Completed on the C side

  #def _dump(depth)
  #  header_str = [dimension, xsize, ysize, zsize, datasize].pack("L5")
  #  ary_str = Marshal.dump(self.to_a)
  #
  #  Marshal.dump([header_str, ary_str])
  #end

  def self._load(str)
    size, nx, ny, nz, items = *str[0, 20].unpack('L5')#('LLLLL')

    # // Patching O:
    nx = [1, nx].max
    ny = [1, ny].max
    nz = [1, nz].max
    items = nx * ny * nz if items == 0

    #p [size, nx, ny, nz, items]

    t = new(*[nx, ny, nz][0, size])
    d = str[20, items * 2].unpack("S#{items}")
    if str.length > (20+items*2)
      a = Marshal.load(str[(20+items*2)...str.length])
      d.collect! do |i|
        if i & 0x8000 == 0x8000
          a[i&~0x8000]
        else
          i
        end
      end
    end
    t.write_ary_to_data(d) rescue nil
    t
  end

  def dup
    Marshal.load(Marshal.dump(self))
  end

  alias clone dup

end
