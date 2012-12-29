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
        try_rtp_path(filename.downcase) do |fn|
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
    @texture.dispose if @texture and !@texture.disposed?
    super
  end

  def disposed?
    super or !@texture or (@texture and @texture.disposed?)
  end

  attr_reader :font

  def font=(new_font)
    @font = new_font
  end

  def width
    @texture.width
  end

  def height
    @texture.height
  end

  def rect
    return RGX::Rect.new(0, 0, width, height)
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

    @texture.render_texture(
      sbitmap.texture, tx, ty,
      src_x: sx, src_y: sy, src_width: sw, src_height: sh,
      alpha: opacity
    )
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

  def blur_n(n=1)
    n.times do blur() end
  end

  def rb_blur()
    normalize_colors = proc { |*colors|
      col_ary = colors.inject([0, 0, 0, 0]) do |r, col|
        r[0] += col.red
        r[1] += col.green
        r[2] += col.blue
        r[3] += col.alpha
        r
      end

      red, green, blue, alpha = col_ary
      size = colors.size

      StarRuby::Color.new(red / size, green / size, blue / size, alpha / size)
    }

    for y in 1...height
      for x in 1...width
        cpx = @texture[x, y]
        lpx = @texture[x - 1, y]
        tpx = @texture[x, y - 1]
        rpx = normalize_colors.(cpx, lpx, tpx)

        @texture[x, y] = rpx
      end
    end

    for y in (height - 2).downto(0)
      for x in (width - 2).downto(0)
        cpx = @texture[x, y]
        rpx = @texture[x + 1, y]
        bpx = @texture[x, y + 1]
        rpx = normalize_colors.(cpx, rpx, bpx)

        @texture[x, y] = rpx
      end
    end

    return self;
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

    RGX::Color.type_check(rgx_color)

    r, g, b, a = *rgx_color.as_ary

    @texture.fill_rect(x, y, w, h, StarRuby::Color.new(r, g, b, a))
    return true
  end

  def rb_gradient_fill_rect(*args)
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

    baser = color1.red
    baseg = color1.green
    baseb = color1.blue
    basea = color1.alpha

    diffr = color2.red   - color1.red
    diffg = color2.green - color1.green
    diffb = color2.blue  - color1.blue
    diffa = color2.alpha - color1.alpha

    color = Color.new.set(color1)

    if vertical
      rF = h.to_f
      dw, dh = w, 1

      enumx = x..x
      enumy = y...(y + h)
      enumr = h.to_i.times
    else
      rF = w.to_f
      dw, dh = 1, h

      enumx = x...(x + w)
      enumy = y..y
      enumr = w.to_i.times
    end

    for dx in enumx
      for dy in enumy
        r = enumr.next / rF

        color.red   = baser + diffr * r
        color.green = baseg + diffg * r
        color.blue  = baseb + diffb * r
        color.alpha = basea + diffa * r

        srby_color = color.to_starruby_color
        @texture.fill_rect(dx, dy, dw, dh, srby_color)
      end
    end
    return true
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
    end

    text = text.to_s
    sr_font   = @font.to_starruby_font
    sr_color  = @font.color.to_starruby_color
    antialias = @font.antialias

    tw, th = sr_font.get_size(text)

    y += (h - th) / 2

    if align == 1
      x += (w - tw) / 2
    elsif align == 2
      x += (w - tw)
    end

    if @font.shadow
      sr_shadow_color = @font.shadow_color.to_starruby_color
      @texture.render_text(
        text, x, y, sr_font, sr_shadow_color, antialias
      )
      x += 1
      y += 1
    end

    if @font.outline
      sr_outline_color = @font.out_color.to_starruby_color
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

    return true
  end

  def text_size(text)
    sr_font = @font.to_starruby_font
    w, h = *sr_font.get_size(text.to_s)
    return Rect.new(0, 0, w, h)
  end

  def hue_change(hue)
    @texture.change_hue!(hue % 360)
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
