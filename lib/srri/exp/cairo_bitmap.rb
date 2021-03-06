#
# rm-srri/lib-exp/sr-cairobitmap.rb
# vr 1.1.0
class SRRI::Bitmap
  def self.bind_from_cairo(cairo_surface)
    new StarRuby::Texture.bind_from_cairo(cairo_surface)
  end
end

class SRRI::CairoBitmap < SRRI::Bitmap
  attr_reader :cr_surface, :cr_context

  def initialize(*args, &block)
    super

    init_cairo
  end

  def init_cairo
    dumpdata = @texture.dump('bgra')
    format   = Cairo::Format::ARGB32
    stride   = Cairo::Format.stride_for_width(format, width);
    @cr_surface = Cairo::ImageSurface.new(dumpdata,
                                          format,
                                          width,
                                          height,
                                          stride)
    @cr_context = Cairo::Context.new(@cr_surface)
    @texture.bind_to_cairo(@cr_surface)
  end

  def dup
    raise SRRI::Error.mk_copy_error(self)
  end

  def clone
    raise SRRI::Error.mk_copy_error(self)
  end

  def dispose_cairo
    (@cr_context.destroy; @cr_context = nil) if @cr_context
    (@cr_surface.destroy; @cr_surface = nil) if @cr_surface
  end

  def dispose
    super
    dispose_cairo
  end
end
