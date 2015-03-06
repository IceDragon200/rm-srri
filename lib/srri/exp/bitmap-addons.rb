#
# rm-srri/lib/srri/exp/bitmap-addon.rb
# vr 1.5.0
#   CHANGELOG
#     V 1.5.0
#       #blend_fill_rect
#         now has a new last argument, blend_type, as fill_rect has been
#         replaced by Texture#render_rect
class SRRI::Bitmap
  def sr_cr_blend(cr, blend_type)
    ##
    # right now it doesn't really matter what blend mode this thing is
    case blend_type
    when StarRuby::Texture::BLEND_NONE
      cr.operator = Cairo::Operator::SOURCE
    when StarRuby::Texture::BLEND_ALPHA
      cr.operator = Cairo::Operator::OVER
    when StarRuby::Texture::BLEND_ADD
      cr.operator = Cairo::Operator::ADD
    when StarRuby::Texture::BLEND_SUBTRACT
      raise(ArgumentError, 'unsupported blend mode :subtract')
      #cr.operator = Cairo::Operator::ADD
    when StarRuby::Texture::BLEND_MULTIPLY
      cr.operator = Cairo::Operator::MULTIPLY
    when StarRuby::Texture::BLEND_DIVIDE
      raise(ArgumentError, 'unsupported blend mode :divide')
      #cr.operator = Cairo::Operator::DIVIDE
    when StarRuby::Texture::BLEND_SRC_MASK
      raise(ArgumentError, 'unsupported blend mode :src_mask')
      #cr.operator = Cairo::Operator::MASK
    when StarRuby::Texture::BLEND_DST_MASK
      raise(ArgumentError, 'unsupported blend mode :dst_mask')
    when StarRuby::Texture::BLEND_CLEAR
      cr.operator = Cairo::Operator::CLEAR
    end
  end

  ##
  # blend_fill_rect(Rect rect, Color color, [BLEND_TYPE blend_type])
  # blend_fill_rect(Integer x, Integer y, Integer width, Integer height,
  #                 Color color, [BLEND_TYPE blend_type])
  def blend_fill_rect(*args)
    check_disposed
    case args.size
    # rect, color
    when 2, 3
      rect, color, blend_type = *args
      x, y, w, h = *Rect.cast(rect)
    # x, y, width, height, color
    when 5, 6
      x, y, w, h, color, blend_type = *args
    else
      raise(ArgumentError, "Expected 2 or 5 but received #{args.size}")
    end
    blend_type ||= StarRuby::Texture::BLEND_ALPHA
    @texture.render_rect(x, y, w, h, color, blend_type)
    self
  end

  ##
  # draw_line(Vector2 v1, Vector2 v2, Color color)
  # draw_line(Integer x1, Integer y1, Integer x2, Integer y2, Color color)
  #   Vector2
  #     can be any object which has a #x, and #y property (Float or Integer)
  def draw_line(*args)
    check_disposed
    case args.size
    # v1, v2, color
    when 3
      v1, v2, color = *args
      x1, y1 = *v1.to_a
      x2, y2 = *v2.to_a
    # x1, y1, x2, y2, color
    when 5
      x1, y1, x2, y2, color = *args
    end
    @texture.render_line(x1, y1, x2, y2, color)
    self
  end

  ##
  # noise(Rect rect, Float delta, Boolean Bipolar) -> self
  def noise(delta=0.1, rect=self.rect, bipolar=true, subtractive=false)
    TextureTool.noise(@texture, Rect.cast(rect), delta, bipolar, subtractive)
    self
  end

  ##
  # crop(Integer x, Integer y, Integer w, Integer h) |
  # crop(Rect rect)                                  | -> Bitmap
  def crop(*args)
    check_disposed
    case args.size
    # rec
    when 1
      rect, = args
      x, y, w, h = *Rect.cast(rect)
    # x, y, width, height, color
    when 4
      x, y, w, h = *args
    end
    Bitmap.new(@texture.crop(x, y, w, h))
  end

  ##
  # pallete -> Array<Color>
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
    result.sort_by! { |a| a.reverse }
    result.map! { |(r, g, b, a)| StarRuby::Color.new(r, g, b, a) }
    return result
  end

  ##
  # fill(Color color) -> self
  def fill(color)
    check_disposed
    @texture.fill(color)
    self
  end

  ##
  #
  def draw_fill_hex(*args)
    check_disposed
    case args.size
    ##
    # (Rect, Color, blend_type)
    when 2, 3
      rect, color, blend_type = *args
      x, y, w, h = *Rect.cast(rect)
    # (x, y, w, h, Color, blend_type)
    when 5, 6
      x, y, w, h, color, blend_type = *args
    else
      raise ArgumentError, "wrong number of arguments #{args.size} expected (2, 3, 5 or 6)"
    end
    return if w <= 0 || h <= 0
    blend_type ||= StarRuby::Texture::BLEND_ALPHA
    r, g, b, a = *(color || [0, 0, 0, 0])
    rf = r / 255.0
    gf = g / 255.0
    bf = b / 255.0
    af = a / 255.0
    if af < 1.0
      bmp = Bitmap.new(w, h)
      bmp.cr_context.save do |cr|
        cr.operator = Cairo::Operator::OVER
        cr.set_source_rgba(rf, gf, bf, 1.0)
        cr.hexagon(w / 2.0, h / 2.0, w, h)
        cr.fill
      end
      x -= w / 2
      y -= h / 2
      @texture.render_texture(bmp.texture, x, y, alpha: a, blend_type: blend_type)
      bmp.dispose
    else
      @texture.cr_context.save do |cr|
        sr_cr_blend(cr, blend_type)
        cr.set_source_rgba(rf, gf, bf, af)
        cr.hexagon(x, y, w, h)
        cr.fill
      end
    end
    return rect
  end

  ##
  # draw_round_rect(Rect rect, Color color, BlendType blend_type, int border)
  # draw_round_rect(int x, int y, int width, int height, Color color,
  #                 BlendType blend_type, int border)
  def draw_round_rect(*args)
    check_disposed
    case args.size
    when 2, 3, 4
      rect, color, blend_type, border = *args
      x, y, w, h = *Rect.cast(rect)
    when 5, 6, 7
      x, y, w, h, color, blend_type, border = *args
    else
      raise ArgumentError, "wrong number of arguments #{args.size} expected (2, 3, 4, 5, 6 or 7)"
    end
    return if w <= 0 || h <= 0
    blend_type ||= StarRuby::Texture::BLEND_ALPHA
    border ||= 4
    if border != 0
      r, g, b, a = *(color || [0, 0, 0, 0])
      rf = r / 255.0
      gf = g / 255.0
      bf = b / 255.0
      af = a / 255.0
      ##
      # Since cairo doesn't handle alpha the same way that StarRuby does
      # we will render the color with full alpha using cairo
      # then blit it back unto the texture
      if af < 1.0
        bmp = Bitmap.new(w, h)
        bmp.texture.cr_context.save do |cr|
          cr.operator = Cairo::Operator::OVER
          cr.set_source_rgba(rf, gf, bf, 1.0)
          cr.rounded_rectangle(0, 0, w, h, border)
          cr.fill
        end
        @texture.render_texture(bmp.texture, x, y, alpha: a, blend_type: blend_type)
        bmp.dispose
      else
        @texture.cr_context.save do |cr|
          sr_cr_blend(cr, blend_type)
          cr.set_source_rgba(rf, gf, bf, af)
          cr.rounded_rectangle(x, y, w, h, border)
          cr.fill
        end
      end
    else
      @texture.render_rect(x, y, w, h, color, blend_type)
    end
    return rect
  end

  ##
  # round_fill_rect(Rect rect, Color color, int border)
  # round_fill_rect(int x, int y, int width, int height, Color color, int border)
  def round_fill_rect(*args)
    pr = args.size == 3 || args.size == 6
    a = args.pop if pr
    args.push(StarRuby::Texture::BLEND_NONE)
    args.push(a) if pr
    draw_round_rect(*args)
  end

  ##
  # round_blend_fill_rect(Rect rect, Color color, BlendType blend_type, int border)
  # round_blend_fill_rect(int x, int y, int width, int height, Color color,
  #                       BlendType blend_type, int border)
  def round_blend_fill_rect(*args)
    draw_round_rect(*args)
  end

  ##
  # round_clear_rect(Rect rect)
  def round_clear_rect(*args)
    if !(args.size == 1 || args.size == 2 || args.size == 4 || args.size == 5)
      raise(ArgumentError,
            "expected 1 or 4 arguments but recieved %d" % args.size)
      return false
    end
    if args.size == 2 || args.size == 5
      a = args.pop
      args.push(nil) # no color
      args.push(StarRuby::Texture::BLEND_CLEAR) # blend
      args.push(a) # border
    else
      args.push(nil)
      args.push(StarRuby::Texture::BLEND_CLEAR) # blend
    end
    draw_round_rect(*args)
  end

  ##
  # Copies a sample/selection of the Bitmap and returns it
  # @overload subsample(rect)
  #   @param [Rect] rect
  # @overload subsample(x, y, width, height)
  #   @param [Integer] x
  #   @param [Integer] y
  #   @param [Integer] width
  #   @param [Integer] height
  # @return [Bitmap]
  def subsample(*args)
    case args.size
    when 1
      r = args.first
    when 4
      r = Rect.new(*args)
    else
      raise ArgumentError,
            "wrong argument number #{args.size} (expected 1, or 4 arguments)"
    end
    nr = self.rect.subsample(r)
    return nil if nr.empty?
    Bitmap.new(nr.width, nr.height).tap { |o| o.blt(0, 0, self, nr.rect) }
  end

  ###
  # @param [String] filename
  ###
  def save_file(filename)
    @texture.save_file(filename)
  end

  private :sr_cr_blend
end
