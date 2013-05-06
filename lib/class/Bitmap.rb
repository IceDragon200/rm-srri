#
# rm-srri/src/class/bitmap.rb
#   dm 22/04/2013
# vr 1.1.1
class SRRI::Bitmap

  include SRRI::Interface::IDisposable

  attr_accessor :texture, :font
  attr_reader :filename # [given_filename, real_filename]

  @@bitmaps = [] # debugging

  def self.bitmaps
    @@bitmaps
  end

  def initialize(*args)
    @texture  = nil
    @filename = nil
    @@bitmaps << self
    case args.size
    when 1 # Path
      obj, = *args # String / Texture
      case obj
      when String
        # Try Path
        SRRI.find_path(obj) do |fn|
          begin
            @texture = StarRuby::Texture.load(fn) # Texture
          rescue StarRuby::StarRubyError => ex
            puts fn
            raise ex
          end
          @filename = [obj, fn]
        end
      # Create Bitmap by binding to a Texture
      when StarRuby::Texture
        @texture = obj
      else
        raise(TypeError,
              "Expected type String or StarRuby::Texture but recieved #{obj.class}")
      end
    when 2 # width, height
      width, height = *args

      raise(ArgumentError, "width too small") if width <= 0
      raise(ArgumentError, "height too small") if height <= 0

      @texture = StarRuby::Texture.new(width, height)
    else
      raise(ArgumentError,
            "expected 1 or 2 arguments but received %d" % args.size)
    end

    @font = SRRI::Font.new
  # clean up texture
  rescue(Exception) => ex
    @texture.dispose if @texture && !@texture.disposed?
    raise(ex)
  end

  def dispose
    super
    @@bitmaps.delete(self)
    @texture.dispose if @texture
  end

  def disposed?
    super || !@texture || (@texture and @texture.disposed?)
  end

  def width
    check_disposed
    @texture.width
  end

  def height
    check_disposed
    @texture.height
  end

  def rect
    check_disposed
    return @texture.rect
  end

  def blt(*args)
    check_disposed
    case args.size
    # x, y, bitmap, rect
    when 4
      tx, ty, sbitmap, srect = *args
      opacity = 255
    # x, y, bitmap, rect, opacity
    when 5
      tx, ty, sbitmap, srect, opacity = *args
    else
      raise(ArgumentError, "expected 4 or 5 but recieved %d" % args.size)
    end

    sx, sy, sw, sh = srect.to_a

    @texture.render_texture(sbitmap.texture, tx, ty,
                            src_x: sx, src_y: sy, src_width: sw, src_height: sh,
                            alpha: opacity, blend_type: :alpha)

    return self
  end

  def stretch_blt(*args)
    check_disposed
    case args.size
    # dest_rect, src_bitmap, src_rect
    when 3
      dest_rect, src_bitmap, src_rect = *args
      opacity = 255
    # dest_rect, src_bitmap, src_rect, opacity
    when 4
      dest_rect, src_bitmap, src_rect, opacity = *args
    else
      raise(ArgumentError, "expected 3 or 4 but received %d" % args.size)
    end

    sx, sy, sw, sh = src_rect.to_a
    dx, dy, dw, dh = dest_rect.to_a

    scale_x = dw / sw.to_f
    scale_y = dh / sh.to_f

    @texture.render_texture(
      src_bitmap.texture, dx, dy,
      src_x: sx, src_y: sy, src_width: sw, src_height: sh,
      alpha: opacity, scale_x: scale_x, scale_y: scale_y
    )
    self
  end

  def clear
    check_disposed
    #@texture.clear # slow
    @texture.fill_rect(0, 0, @texture.width, @texture.height,
                       SRRI::COLOR_TRANS)
    self
  end

  def clear_rect(*args)
    check_disposed
    case args.size
    # rect
    when 1
      rect, = *args
      x, y, w, h = *rect.to_a
    # x, y, width, height
    when 4
      x, y, w, h = *args
    else
      raise(ArgumentError)
    end

    @texture.fill_rect(x, y, w, h, SRRI::COLOR_TRANS)
    self
  end

  # @overwrite
  def blur
    check_disposed
    @texture.blur
    return self
  end

  def radial_blur(angle, division)
    check_disposed
    puts "fixme: Bitmap#radial_blur"
    self
  end

  ##
  # set_pixel(Integer x, Integer y, Color color)
  def set_pixel(x, y, color)
    check_disposed
    @texture[x, y] = color
    #@texture.render_pixel(x, y, color)
    self
  end

  ##
  # get_pixel(Integer x, Integer y) -> Color
  def get_pixel(x, y)
    check_disposed
    return @texture[x, y]
  end

  ##
  # fill_rect(Rect rect, Color color)
  # fill_rect(Integer x, Integer y, Integer width, Integer height, Color color)
  def fill_rect(*args)
    check_disposed
    case args.size
    # rect, color
    when 2
      rect, color = *args
      x, y, w, h = rect.to_a
    # x, y, width, height, color
    when 5
      x, y, w, h, color = *args
    else
      raise(ArgumentError, "expected 2, or 5 but received #{args.size}")
    end

    @texture.fill_rect(x, y, w, h, color)

    return self
  end

  ##
  # gradient_fill_rect(Rect rect, Color color1, Color color2)
  # gradient_fill_rect(Rect rect, Color color1, Color color2, Boolean vertical)
  # gradient_fill_rect(Integer x, Integer y, Integer width, Integer height,
  #                    Color color1, Color color2)
  # gradient_fill_rect(Integer x, Integer y, Integer width, Integer height,
  #                    Color color1, Color color2, Boolean vertical)
  def gradient_fill_rect(*args)
    check_disposed
    vertical = false
    case args.size
    # rect, color1, color2
    when 3
      rect, color1, color2 = *args
      x, y, w, h = *rect.to_a
    # rect, color1, color2, vertical
    when 4
      rect, color1, color2, vertical = *args
      x, y, w, h = *rect.to_a
    # x, y, width, height, color1, color2
    when 6
      x, y, w, h, color1, color2 = *args
    # x, y, width, height, color1, color2, vertical
    when 7
      x, y, w, h, color1, color2, vertical = *args
    else
      raise(ArgumentError, "expected 3, 4, 6 or 7 but recieved #{args.size}")
    end

    @texture.gradient_fill_rect(x, y, w, h, color1, color2, vertical)

    return self;
  end

  ##
  # draw_text(Rect rect, String text)
  # draw_text(Rect rect, String text, Integer align)
  # draw_text(Integer x, Integer y, Integer width, Integer height, String text)
  # draw_text(Integer x, Integer y, Integer width, Integer height, String text,
  #           Integer align)
  def draw_text(*args)
    check_disposed
    align = 0
    case args.size
    # rect, text
    when 2
      rect, text = *args
      x, y, w, h = rect.to_a
    # rect, text, align
    when 3
      rect, text, align = *args
      x, y, w, h = rect.to_a
    # x, y, width, height, text
    when 5
      x, y, w, h, text = *args
    # x, y, width, height, text, align
    when 6
      x, y, w, h, text, align = *args
    else
      raise(ArgumentError, "expected 2, 3, 5, or 6 but recieved #{args.size}")
    end

    text = text.to_s
    sr_font   = @font.to_strb_font

    sr_shadow_color  = @font.shadow_color
    sr_outline_color = @font.out_color
    sr_color         = @font.color

    if @font.exconfig[:flip_shadow_color]
      sr_color, sr_shadow_color = sr_shadow_color, sr_color
    else
      if @font.exconfig[:flip_outline_color]
        sr_color, sr_outline_color = sr_outline_color, sr_color
      end
    end

    antialias = @font.antialias

    tw, th = sr_font.get_size(text)

    y += (h - th) / 2

    if align == 1 # Align to Center
      x += (w - tw) / 2
    elsif align == 2
      x += (w - tw) # Align to Right
    end

    if @font.shadow
      org_x, org_y = x, y

      # shift shadow over
      anchor, amount = *@font.shadow_conf
      unless defined?(Surface)
        x += amount
        y += amount
      else
        v = Surface::Tool.anchor_to_vec2(anchor)
        x += amount * v.x
        y += amount * v.y
      end

      @texture.render_text(
        text, x, y, sr_font, sr_shadow_color, antialias
      )

      x, y = org_x, org_y
    end

    # actual rendition
    if @font.outline
      for fx in -1..1
        for fy in -1..1
          @texture.render_text(
            text, x + fx, y + fy, sr_font, sr_outline_color, antialias
          )
        end
      end
    end

    @texture.render_text(
      text, x, y, sr_font, sr_color, antialias
    )

    return self
  end

  ##
  # text_size(String text) -> Rect
  def text_size(text)
    sr_font = @font.to_strb_font
    w, h = *sr_font.get_size(text.to_s)
    return SRRI::Rect.new(0, 0, w, h)
  end

  ##
  # hue_change(Integer hue)
  def hue_change(hue)
    check_disposed
    @texture.change_hue!(hue % 360)
    return self
  end

  def dup
    check_disposed
    bmp = SRRI::Bitmap.new(@texture.dup)
    bmp.font = @font.dup
    return bmp
  end

  def clone
    check_disposed
    bmp = SRRI::Bitmap.new(@texture.clone)
    bmp.font = @font.clone
    return bmp
  end

  def pallete
    check_disposed
    result = []
    for y in 0...@texture.height
      for x in 0...@texture.width
        col_ary = @texture[x, y].to_a
        col_ary.map!(&:to_i)
        result.push(col_ary) unless result.include?(col_ary)
      end
    end

    result.replace(
      result.sort_by do |a|
        a.reverse
      end
    )
    result.collect! do
      |(r, g, b, a)|

      StarRuby::Color.new(r, g, b, a)
    end

    return result
  end

  private :check_disposed

end
