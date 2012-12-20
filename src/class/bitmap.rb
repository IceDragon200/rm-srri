module StarRuby

  class Texture

    def rect
      Rect.new(0, 0, width, height)
    end

  end

end

class RGX::Bitmap

  include Interface::IDisposable

  attr_accessor :texture

  def initialize(*args)
    case args.size
    when 1 # Path
      filename, = *args # String
      # Try RTP

      try_rtp_path(filename.downcase) do |fn|
        @texture = StarRuby::Texture.load(fn) # Texture
      end
    when 2 # width, height
      width, height = *args
      @texture = StarRuby::Texture.new(width, height)
    end

    @font = RGX::Font.new
    self
  end

  def dispose
    super
    @texture.dispose
  end

  def disposed?
    super or @texture.disposed?
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
    return Rect.new(0, 0, width, height)
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

    @texture.fill_rect(x, y, w, h, StarRuby::Color.new(0, 0, 0, 0))
  end

  def blur_n(radius=1)
    source = @texture.dup
    dest = @texture
    for y in (radius)...(height - radius)
      for x in (radius)...(width - radius)
        scol = source[x, y]
        for ky in (-radius)...radius
          for kx in (-radius)...radius
            flt = kx.abs.to_f / radius * ky.abs.to_f / radius
            #total / (radius * 2 + 1) ^ 2
            col = scol.to_rgx_color
            col.red   = col.red * flt
            col.green = col.green * flt
            col.blue  = col.blue * flt
            col.alpha = col.alpha * flt
            col = col.to_starruby_color
            dest[x + kx, y + ky] = col
          end
        end
      end
    end
    source.dispose
  end

  def blur()
    puts "fixme: Bitmap#blur"
  end

  def radial_blur(angle, division)
    puts "fixme: Bitmap#radial_blur"
  end

  def set_pixel(x, y, rgss_color)
    r, g, b, a = *rgss_color.as_ary
    @texture.render_pixel(x, y, StarRuby::Color.new(r, g, b, a))
    return true
  end

  def get_pixel(x, y)
    r, g, b, a = @texture[x, y].as_ary
    return Color.new(r, g, b, a)
  end

  def fill_rect(*args)
    case args.size
    # rect, color
    when 2
      rect, rgss_color = *args
      x, y, w, h = rect.as_ary
    # x, y, width, height, rgss_color
    when 5
      x, y, w, h, rgss_color = *args
    else
      raise(ArgumentError)
    end

    r, g, b, a = *rgss_color.as_ary

    @texture.fill_rect(x, y, w, h, StarRuby::Color.new(r, g, b, a))
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
      raise(ArgumentError)
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

    color_trans = proc do |r|
      color.red   = baser + (diffr) * r
      color.green = baseg + (diffg) * r
      color.blue  = baseb + (diffb) * r
      color.alpha = basea + (diffa) * r
      color
    end

    if vertical
      hF = h.to_f

      h.to_i.times do |iy|
        r = iy / hF
        srby_color = color_trans.call(r).to_starruby_color
        @texture.fill_rect(x, y + iy, w, 1, srby_color)
      end
    else
      wF = w.to_f

      w.to_i.times do |ix|
        r = ix / wF
        srby_color = color_trans.call(r).to_starruby_color
        @texture.fill_rect(x + ix, y, 1, h, srby_color)
      end
    end

    return true
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

end
