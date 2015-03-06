require 'starruby/texture'
require 'srri/class/rgss_error'
require 'srri/class/rect'
require 'srri/class/color'
require 'srri/class/font'
require 'srri/interface/i_disposable'

module SRRI
  class Bitmap
    include Interface::IDisposable

    attr_accessor :texture
    attr_accessor :font
    attr_reader :filename # [given_filename, real_filename]

    @@default_blend_type = :alpha
    @@bitmaps = [] # debugging

    def initialize(*args)
      @texture  = nil
      @filename = nil
      case args.size
      when 1 # Path
        obj, = *args # String / Texture
        case obj
        when String
          # Try Path
          SRRI.find_path(obj, [".png", ".jpg", ".bmp"]) do |fn|
            begin
              @texture = StarRuby::Texture.load_file(fn) # Texture
            rescue StarRuby::StarRubyError => ex
              STDERR.puts "Could not Find: #{fn}"
              raise ex
            end
            @filename = [obj, fn]
          end
        # Create Bitmap by binding to a Texture
        when StarRuby::Texture
          @texture = obj
        else
          raise TypeError,
                "Expected type String or StarRuby::Texture but recieved #{obj.class}"
        end
      when 2 # width, height
        width, height = *args

        raise RGSSError, "width too small" if width <= 0
        raise RGSSError, "height too small" if height <= 0

        @texture = StarRuby::Texture.new(width, height)
      else
        raise ArgumentError,
              "expected 1 or 2 arguments but received %d" % args.size
      end

      @font = Font.new
      @@bitmaps << self
    # clean up texture
    rescue Exception  => ex
      @texture.dispose if @texture && !@texture.disposed?
      raise ex
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
      Rect.new(*@texture.rect)
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

      sx, sy, sw, sh = Rect.cast(srect).to_a

      @texture.render_texture(sbitmap.texture, tx, ty,
                              src_x: sx, src_y: sy, src_width: sw, src_height: sh,
                              alpha: opacity, blend_type: @@default_blend_type)

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

      sx, sy, sw, sh = Rect.cast(src_rect).to_a
      dx, dy, dw, dh = Rect.cast(dest_rect).to_a

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
      @texture.clear # slow
      #@texture.render_rect(0, 0, @texture.width, @texture.height,
      #                     SRRI::COLOR_TRANS)
      self
    end

    def clear_rect(*args)
      check_disposed
      case args.size
      # rect
      when 1
        rect, = *args
        x, y, w, h = Rect.cast(rect).to_a
      # x, y, width, height
      when 4
        x, y, w, h = *args
      else
        raise(ArgumentError, "expected 1 or 4 arguments but received %d" % args.size)
      end
      @texture.clear_rect(x, y, w, h)
      self
    end

    ##
    # blur
    def blur
      check_disposed
      @texture.blur
      self
    end

    ##
    # radial_blur(Integer angle, Integer division)
    def radial_blur(angle, division)
      check_disposed
      puts 'TODO: Bitmap#radial_blur'
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
      if x < 0 || width < x || y < 0 || height < 0
        return Color.new(0, 0, 0, 0)
      else
        Color.new(@texture[x, y])
      end
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
        x, y, w, h = Rect.cast(rect).to_a
      # x, y, width, height, color
      when 5
        x, y, w, h, color = *args
      else
        raise(ArgumentError, "expected 2, or 5 but received #{args.size}")
      end
      @texture.render_rect(x, y, w, h, color, :none)
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
        x, y, w, h = Rect.cast(rect).to_a
      # rect, color1, color2, vertical
      when 4
        rect, color1, color2, vertical = *args
        x, y, w, h = Rect.cast(rect).to_a
      # x, y, width, height, color1, color2
      when 6
        x, y, w, h, color1, color2 = *args
      # x, y, width, height, color1, color2, vertical
      when 7
        x, y, w, h, color1, color2, vertical = *args
      else
        raise ArgumentError, "expected 3, 4, 6 or 7 but recieved #{args.size}"
      end
      @texture.gradient_fill_rect(x, y, w, h, color1, color2, vertical)
      return self
    end

    ###
    # draw_text(Rect rect, String text)
    # draw_text(Rect rect, String text, ALIGN align)
    # draw_text(Rect rect, String text, ANCHOR align)
    # draw_text(Integer x, Integer y, Integer width, Integer height, String text)
    # draw_text(Integer x, Integer y, Integer width, Integer height, String text,
    #           ALIGN align)
    # draw_text(Integer x, Integer y, Integer width, Integer height, String text,
    #           ANCHOR align)
    # draw_text(Hash<Symbol, Object*>)
    ###
    def draw_text(*args)
      check_disposed
      return unless font.valid?
      sr_font   = @font.to_strb_font
      return unless sr_font

      align = 0
      case args.size
      # Hash hash
      when 1
        x, y, w, h = 0, 0, 0, 0
        text = ""
        align = 0
        hsh, = args
        x      = hsh[:x]      if hsh.has_key?(:x)
        y      = hsh[:y]      if hsh.has_key?(:y)
        width  = hsh[:width]  if hsh.has_key?(:width)
        height = hsh[:height] if hsh.has_key?(:height)
        text   = hsh[:text]   if hsh.has_key?(:text)
        align  = hsh[:align]  if hsh.has_key?(:align)
        x, y, w, h = Rect.cast(hsh[:rect]).to_a if hsh.has_key?(:rect)
      # Rect rect, String text
      when 2
        rect, text = *args
        x, y, w, h = Rect.cast(rect).to_a
      # Rect rect, String text, ALIGN align
      # Rect rect, String text, ANCHOR align
      when 3
        rect, text, align = *args
        x, y, w, h = Rect.cast(rect).to_a
      # Integer x, Integer y, Integer width, Integer height, String text
      when 5
        x, y, w, h, text = *args
      # Integer x, Integer y, Integer width, Integer height, String text, ALIGN align
      # Integer x, Integer y, Integer width, Integer height, String text, ANCHOR align
      when 6
        x, y, w, h, text, align = *args
      else
        raise(ArgumentError, "expected 2, 3, 5, or 6 but recieved #{args.size}")
      end

      sr_shadow_color  = @font.shadow_color
      sr_outline_color = @font.out_color
      sr_color         = @font.color

      blend_type = 1 # Alpha

      if @font.exconfig[:flip_shadow_color]
        sr_color, sr_shadow_color = sr_shadow_color, sr_color
      elsif @font.exconfig[:flip_outline_color]
        sr_color, sr_outline_color = sr_outline_color, sr_color
      end

      antialias = @font.antialias

      text = text.to_s
      tw, th = sr_font.get_size(text)

      # use MACL::Surface::ANCHOR(s)
      # 3 dimensional anchor
      if align >= 0x3000
        ax = (align >> 0) & 0xF
        ay = (align >> 4) & 0xF
        #az = (align >> 8) & 0xF
        warn("Using 3D ANCHOR in a 2D context")
      # 2 dimensional anchor
      elsif align >= 0x200
        ax = (align >> 0) & 0xF
        ay = (align >> 4) & 0xF
      # default to RGSS2/3 style alignment
      else
        ax = align + 1
        ay = 2
      end

      case ax
      when 0 then nil               # NULL
      when 1 then x                 # LEFT
      when 2 then x += (w - tw) / 2 # CENTER
      when 3 then x += (w - tw)     # RIGHT
      end

      case ay
      when 0 then nil               # NULL
      when 1 then y                 # TOP
      when 2 then y += (h - th) / 2 # CENTER
      when 3 then y += (h - th)     # BOTTOM
      end

      if @font.shadow
        org_x, org_y = x, y

        # shift shadow over
        anchor, amount = *@font.shadow_conf
        v = SRRI.anchor_to_v2f_a(SRRI.cast_anchor(anchor))
        x += amount * v[0]
        y += amount * v[1]

        @texture.render_text(text, x, y, sr_font, sr_shadow_color,
                             blend_type, antialias)

        x, y = org_x, org_y
      end

      # actual rendition
      if @font.outline
        for fx in -1..1
          for fy in -1..1
            @texture.render_text(text, x + fx, y + fy, sr_font, sr_outline_color,
                                 blend_type, antialias)

          end
        end
      end

      #p [text, x, y, sr_font, sr_color, antialias]
      #p [text, text.class]
      @texture.render_text(text, x, y, sr_font, sr_color, blend_type, antialias)

      return self
    end

    ##
    # text_size(String text) -> Rect
    def text_size(text)
      sr_font = @font.to_strb_font
      return Rect.new(0, 0, 1, 1) unless sr_font
      w, h = *sr_font.get_size(text.to_s)
      return Rect.new(0, 0, w, h)
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
      bmp = Bitmap.new(@texture.dup)
      bmp.font = @font.dup
      return bmp
    end

    def clone
      check_disposed
      bmp = Bitmap.new(@texture.clone)
      bmp.font = @font.clone
      return bmp
    end

    def self.bitmaps
      @@bitmaps
    end

    def self.default_blend_type
      @@default_blend_type
    end

    def self.default_blend_type=(new_blend_type)
      @@default_blend_type = new_blend_type
    end

    private :check_disposed
  end
end
