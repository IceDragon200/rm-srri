#
# rm-srri/lib-exp/texture-cairo-init.rb
# vr 1.2.0
class StarRuby::Texture

  attr_accessor :_cairo_surface, :_cairo_context

  # use init_cairo_bind(true) when initializing the screen Texture
  #   or you might run into some trouble :x
  def init_cairo_bind(dry=false)
    args = if self.disposed? || dry
      [width, height];
    else
      dumpdata = dump('bgra');
      format   = Cairo::Format::ARGB32;
      stride   = Cairo::Format.stride_for_width(format, width);
      [dumpdata, format, width, height, stride];
    end
    @_cairo_surface = Cairo::ImageSurface.new(*args)
    @_cairo_context = Cairo::Context.new(@_cairo_surface)
    bind_to_cairo(@_cairo_surface)
  end

  # release the cairo surface
  alias :cairo_dup :dup
  def dup
    new_obj = cairo_dup
    if new_obj._cairo_surface || new_obj._cairo_context
      new_obj._cairo_surface = nil
      new_obj._cairo_context = nil
    end
    return new_obj
  end
  alias :clone :dup

  def release_cairo
    unbind
    @_cairo_surface = nil
    @_cairo_context = nil
  end

  alias :post_cairo_dispose :dispose
  def dispose
    (@_cairo_surface.destroy; @_cairo_surface = nil) if @_cairo_surface
    (@_cairo_context.destroy; @_cairo_context = nil) if @_cairo_context
    post_cairo_dispose
  end

  def cairo
    raise(RuntimeError, "Cannot modify disposed Texture") if disposed?
    init_cairo_bind unless @_cairo_context
    @_cairo_context.save do
      yield @_cairo_context
    end
    self
  end

  ##
  # ::cairo_new(Integer w, Integer h)
  #   Creates a new texture with cairo bindings setup
  def self.cairo_new(w, h)
    texture = new(w, h)
    texture.init_cairo_bind(true)
    return texture
  end

end
