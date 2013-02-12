#
# src/class/bitmap.rb
# vr 0.83
module StarRuby

  class Texture

    def rect
      RGX::Rect.new(0, 0, width, height)
    end

  end

end

class RGX::Bitmap

  # Transparent Color used for clearing
  SR_TRANSPARENT = StarRuby::Color.new(255, 255, 255, 0).freeze

  include Interface::IDisposable

  attr_accessor :texture

  def initialize(*args)
    case args.size
    when 1 # Path
      filename, = *args # String / Texture
      case filename
      when String
        # Try RTP
        try_rtp_path(filename) do |fn|
          @texture = StarRuby::Texture.load(fn) # Texture
        end
      when StarRuby::Texture
        @texture = filename
      end
    when 2 # width, height
      width, height = *args

      raise(ArgumentError, "width too small") if width <= 0
      raise(ArgumentError, "height too small") if height <= 0

      @texture = StarRuby::Texture.new(width, height)
    end

    @font = RGX::Font.new
  rescue(Exception) => ex
    @texture.dispose if @texture && !@texture.disposed?
    raise(ex)
  end

  def dispose
    @texture.dispose if @texture
    super
  end

  def disposed?
    super or !@texture or (@texture and @texture.disposed?)
  end

  def width
    @texture.width
  end

  def height
    @texture.height
  end

  def blt(*args)
    case args.size
    # x, y, bitmap, rect
    when 4
      tx, ty, sbitmap, srect = *args
      opacity = 255
    # x, y, bitmap, rect, opacity
    when 5
      tx, ty, sbitmap, srect, opacity = *args
    else
      raise(ArgumentError)
    end

    sx, sy, sw, sh = srect.as_ary

    TextureTool.render_texture_fast(
      @texture, tx, ty,
      sbitmap.texture,
      sx, sy, sw, sh,
      opacity, 1)

    return true
  end

  def stretch_blt(*args)
    case args.size
    # dest_rect, src_bitmap, src_rect
    when 3
      dest_rect, src_bitmap, src_rect = *args
      opacity = 255
    # dest_rect, src_bitmap, src_rect, opacity
    when 4
      dest_rect, src_bitmap, src_rect, opacity = *args
    end

    sx, sy, sw, sh = src_rect.as_ary
    dx, dy, dw, dh = dest_rect.as_ary

    scale_x = dw / sw.to_f
    scale_y = dh / sh.to_f

    @texture.render_texture(
      src_bitmap.texture, dx, dy,
      src_x: sx, src_y: sy, src_width: sw, src_height: sh,
      alpha: opacity, scale_x: scale_x, scale_y: scale_y
    )
  end

  def clear
    @texture.clear
  end

  def clear_rect(*args)
    case args.size
    # rect
    when 1
      rect, = *args
      x, y, w, h = *rect.as_ary
    # x, y, width, height
    when 4
      x, y, w, h = *args
    else
      raise(ArgumentError)
    end

    @texture.fill_rect(x, y, w, h, SR_TRANSPARENT)
  end

  # @overwrite
  def blur
    @texture.blur

    return self;
  end

  def radial_blur(angle, division)
    puts "fixme: Bitmap#radial_blur"
  end

  def set_pixel(x, y, rgx_color)
    r, g, b, a = *rgx_color.as_ary
    @texture.render_pixel(x, y, StarRuby::Color.new(r, g, b, a))
    return true
  end

  def get_pixel(x, y)
    r, g, b, a = @texture[x, y].as_ary
    return RGX::Color.new(r, g, b, a)
  end

  def fill_rect(*args)
    case args.size
    # rect, color
    when 2
      rect, rgx_color = *args
      x, y, w, h = rect.as_ary
    # x, y, width, height, rgx_color
    when 5
      x, y, w, h, rgx_color = *args
    else
      raise(ArgumentError)
    end

    @texture.fill_rect(x, y, w, h, rgx_color.to_starruby_color)

    return self
  end

  def blend_fill_rect(*args)
    case args.size
    # rect, color
    when 2
      rect, rgx_color = *args
      x, y, w, h = rect.as_ary
    # x, y, width, height, rgx_color
    when 5
      x, y, w, h, rgx_color = *args
    else
      raise(ArgumentError)
    end

    @texture.render_rect(x, y, w, h, rgx_color.to_starruby_color)

    return self

  end

  def gradient_fill_rect(*args)
    vertical = false
    case args.size
    # rect, color1, color2
    when 3
      rect, color1, color2 = *args
      x, y, w, h = *rect.as_ary
    # rect, color1, color2, vertical
    when 4
      rect, color1, color2, vertical = *args
      x, y, w, h = *rect.as_ary
    # x, y, width, height, color1, color2
    when 6
      x, y, w, h, color1, color2 = *args
    # x, y, width, height, color1, color2, vertical
    when 7
      x, y, w, h, color1, color2, vertical = *args
    else
      raise(ArgumentError, "expected 3, 4, 6 or 7 but recieved #{args.size}")
    end

    @texture.gradient_fill_rect(x, y, w, h,
      color1.to_starruby_color, color2.to_starruby_color, vertical)

    return self;
  end

  def draw_text(*args)
    align = 0
    case args.size
    # rect, text
    when 2
      rect, text = *args
      x, y, w, h = rect.as_ary
    # rect, text, align
    when 3
      rect, text, align = *args
      x, y, w, h = rect.as_ary
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
    sr_font   = @font.to_starruby_font

    sr_shadow_color  = @font.shadow_color.to_starruby_color
    sr_outline_color = @font.out_color.to_starruby_color
    sr_color         = @font.color.to_starruby_color

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

    if align == 1
      x += (w - tw) / 2
    elsif align == 2
      x += (w - tw)
    end

    if @font.shadow
      org_x, org_y = x, y

      # shift shadow over
      anchor, amount = *@font.shadow_conf
      unless defined?(Surface)
        x += amount
        y += amount
      else
        xp, yp = Surface::Tool.anchor_to_unary(anchor)
        x += amount * xp
        y += amount * yp
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

  def text_size(text)
    sr_font = @font.to_starruby_font
    w, h = *sr_font.get_size(text.to_s)
    return Rect.new(0, 0, w, h)
  end

  def hue_change(hue)
    @texture.change_hue!(hue % 360)
    return self
  end

  # RGX Patches
  def dup
    bmp = Bitmap.new(@texture.clone)
    bmp.font = @font.clone
    return bmp
  end

  alias clone dup

  # RGX Extensions
  def pallete
    result = []
    for y in 0...@texture.height
      for x in 0...@texture.width
        col_ary = @texture[x, y].as_ary
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

      RGX::Color.new(r, g, b, a)
    end

    return result
  end

end
