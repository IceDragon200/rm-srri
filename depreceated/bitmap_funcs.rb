class SRRI::Bitmap

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

        @texture.fill_rect(dx, dy, dw, dh, color)
      end
    end

    return self
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

end
