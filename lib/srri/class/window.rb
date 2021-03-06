require 'srri/class/bitmap'
require 'srri/class/color'
require 'srri/class/rect'
require 'srri/class/tone'
require 'srri/interface/i_renderable'
require 'srri/interface/i_z_order'

module SRRI
  class Window
    include Interface::IRenderable
    include Interface::IZOrder

    ARROW_RECT_UP    = Rect.new(80 + 8, 16, 16, 8).freeze
    ARROW_RECT_DOWN  = Rect.new(80 + 8, 16 + 16 + 8, 16, 8).freeze
    ARROW_RECT_LEFT  = Rect.new(80, 16 + 8, 8, 16).freeze
    ARROW_RECT_RIGHT = Rect.new(80 + 16 + 8, 16 + 8, 8, 16).freeze
    PAUSE_RECTS = [Rect.new(96, 64, 16, 16).freeze,
                   Rect.new(96 + 16, 64, 16, 16).freeze,
                   Rect.new(96, 64 + 16, 16, 16).freeze,
                   Rect.new(96 + 16, 64 + 16, 16, 16).freeze]

    register_renderable('Window')

    def render(texture)
      return false if @_disposed
      return false unless @visible
      return false if @width <= 0
      return false if @height <= 0
      return false if @viewport and !@viewport.visible

      unless @redrawn
        remake_window
        redraw_window
      end

      view = (@viewport || Graphics)
      view.translate(@x, @y) do |vx, vy, vrect|
        pad, pad2 = @padding, @padding * 2

        # ContentBackground
        tr, tg, tb, ta = @tone.to_a
        ay, ax = 0, 0
        #scale_x = @openness / 255.0
        openness_rate = @openness / 255.0
        xopacity_rate = 1.0 #openness_rate
        scale_x = 1.0
        scale_y = openness_rate
        #ax = ((@width / 2.0) * (1 - scale_x)).to_i if scale_x != 1.0
        ay = ((@height / 2.0) * (1 - scale_y)).to_i if scale_y != 1.0

        #no_scale = (scale_x == 1.0 and scale_y == 1.0)

        dx, dy = vx + ax, vy + ay

        sx, sy = 0, 0
        sw, sh = @_texture_content_background.width,
          @_texture_content_background.height

        diff_x = (vx - vrect.x)
        diff_y = (vy - vrect.y)

        if diff_x < 0
          sx -= diff_x
          sw += diff_x
        end
        if diff_y < 0
          sy -= diff_y
          sh += diff_y
        end

        if sw > 0 and sh > 0
          texture.render_texture(
            @_texture_content_background, dx, dy,
            src_x: sx, src_y: sy, src_width: sw, src_height: sh,
            tone_red: tr, tone_green: tg, tone_blue: tb, saturation: 255 - ta,
            alpha: ((@back_opacity * @opacity) / 255) * xopacity_rate,
            scale_x: scale_x, scale_y: scale_y, tone: @tone,
            blend_type: :alpha
          )
        end

        sw, sh = @_texture_window_skin.width, @_texture_window_skin.height

        if diff_x < 0
          sw += diff_x
        end
        if diff_y < 0
          sh += diff_y
        end

        if sw > 0 and sh > 0
          # Window Skin
          texture.render_texture(@_texture_window_skin, dx, dy,
                                 src_x: sx, src_y: sy, src_width: sw, src_height: sh,
                                 alpha: @opacity * xopacity_rate,
                                 scale_x: scale_x, scale_y: scale_y,
                                 blend_type: :alpha)
        end

        #return if @openness < 255 # true RGSS Behaviour

        if @_cursor_texture and (@cursor_rect.width != @_cursor_texture.width or
         @cursor_rect.height != @_cursor_texture.height)
          @_cursor_texture.dispose
          @_cursor_texture = nil
        end

        unless @cursor_rect.empty? || @openness < 255
          redraw_cursor() unless @_cursor_texture
          cdx = vx + pad + @cursor_rect.x - @ox
          cdy = vy + pad + @cursor_rect.y - @oy
          cursor_op = [[(@_cursor_opacity * xopacity_rate).to_i, 0].max, 255].min
          texture.render_texture(@_cursor_texture, cdx, cdy, alpha: cursor_op,
                                 blend_type: :alpha)
        end

        if @contents and !@contents.disposed?
          sx, sy = @ox, @oy
          sw, sh = [@width - pad2, @contents.width].min,
            [@height - pad2, @contents.height].min

          diff_x = (vx - vrect.x)
          diff_y = (vy - vrect.y)

          if diff_x < 0
            sx -= diff_x
            sw += diff_x
          end
          if diff_y < 0
            sy -= diff_y
            sh += diff_y
          end

          texture.render_texture(
            @contents.texture, dx + pad, dy + pad,
            src_x: sx, src_y: sy, src_width: sw, src_height: sh,
            alpha: @contents_opacity * xopacity_rate,
            # SRRI Behaviour
            scale_x: scale_x, scale_y: scale_y,
            blend_type: :alpha
          )
        end

        if @arrows_visible && @contents && !@contents.disposed? && @openness > 0
          arrow_padding = 4
          cntx = dx + (@width - 16) / 2
          cnty = dy + (@height - 16) / 2

          if sx > 0
            texture.render_texture(
              @windowskin.texture, dx + arrow_padding, cnty,
              src_rect: ARROW_RECT_LEFT,
              alpha: 0xFF, blend_type: :alpha
            )
          end

          if (sw + sx) < @contents.width
            texture.render_texture(
              @windowskin.texture, dx + @width - 8 - arrow_padding, cnty,
              src_rect: ARROW_RECT_RIGHT,
              alpha: 0xFF, blend_type: :alpha
            )
          end

          if sy > 0
            texture.render_texture(
              @windowskin.texture, cntx, dy + arrow_padding,
              src_rect: ARROW_RECT_UP,
              alpha: 0xFF, blend_type: :alpha
            )
          end

          if (sh + sy) < @contents.height
            texture.render_texture(
              @windowskin.texture, cntx, dy + @height - 8 - arrow_padding,
              src_rect: ARROW_RECT_DOWN,
              alpha: 0xFF, blend_type: :alpha
            )
          end
        end

        if @pause
          texture.render_texture(
            @windowskin.texture, dx + (@width - 16) / 2, dy + @height - 16,
              src_rect: PAUSE_RECTS[@_pause_index],
              alpha: 0xFF, blend_type: :alpha
          )
        end

      end
    end

   private

    def redraw_cursor
      cw, ch = @cursor_rect.width, @cursor_rect.height
      @_cursor_texture = StarRuby::Texture.new(cw, ch)
      #scale_x = cw / 32.0
      #scale_y = ch / 32.0
      src_texture = @windowskin.texture
      dprops = { src_x: 64, src_y: 64, src_width: 8, src_height: 8 }
      props = dprops.dup

      # top-left
      @_cursor_texture.render_texture(src_texture, 0, 0, props)
      # top-right
      props[:src_x] += 24
      @_cursor_texture.render_texture(src_texture, cw - 8, 0, props)
      # top
      TextureTool.loop_texture(@_cursor_texture, Rect.new(8, 0, cw - 16, 8),
                               src_texture, Rect.new(64 + 8, 64, 16, 8))
      # mid-left
      TextureTool.loop_texture(@_cursor_texture, Rect.new(0, 8, 8, ch - 16),
                               src_texture, Rect.new(64, 64 + 8, 8, 16))
      # mid-right
      TextureTool.loop_texture(@_cursor_texture, Rect.new(cw - 8, 8, 8, ch - 16),
                               src_texture, Rect.new(64 + 24, 64 + 8, 8, 16))
      # mid
      TextureTool.loop_texture(@_cursor_texture, Rect.new(8, 8, cw - 16, ch - 16),
                               src_texture, Rect.new(64 + 8, 64 + 8, 16, 16))
      props = dprops.dup
      props[:src_y] += 24
      # bottom-left
      @_cursor_texture.render_texture(src_texture, 0, ch - 8, props)
      # bottom-right
      props[:src_x] += 24
      @_cursor_texture.render_texture(src_texture, cw - 8, ch - 8, props)
      # bottom
      TextureTool.loop_texture(@_cursor_texture, Rect.new(8, ch - 8, cw - 16, 8),
                               src_texture, Rect.new(64 + 8, 64 + 24, 16, 8))
    end

    def trash_window
      @_texture_content_background.dispose if @_texture_content_background
      @_texture_window_skin.dispose if @_texture_window_skin
      @_texture_content_background = nil
      @_texture_window_skin = nil
      @redrawn = false
    end

    def remake_window
      return if @width <= 0
      return if @height <= 0

      @_texture_content_background ||= StarRuby::Texture.new(@width, @height)
      @_texture_window_skin ||= StarRuby::Texture.new(@width, @height)
    end

    def redraw_window
      return unless @_texture_content_background
      return unless @_texture_window_skin

      @_texture_content_background.clear
      @_texture_window_skin.clear

      return unless @windowskin

      background_rect = @_texture_content_background.rect.dup
      #background_rect.x      += 4
      #background_rect.y      += 4
      #background_rect.width  -= 8
      #background_rect.height -= 8

      ### Background
      if @_looped_background
        TextureTool.loop_texture(@_texture_content_background, background_rect,
                                 @windowskin.texture, Rect.new(0, 0, 64, 64))
      else
        @_texture_content_background.render_texture(
          @windowskin.texture, 0, 0,
          src_x: 0, src_y: 0, src_width: 64, src_height: 64,
          scale_x: @width  / 64.0,
          scale_y: @height / 64.0
        )
      end

      TextureTool.loop_texture(@_texture_content_background, background_rect,
                               @windowskin.texture, Rect.new(0, 64, 64, 64))
      offset = 2
      @_texture_content_background.clear_rect(0, 0,
                                              offset, background_rect.height)
      @_texture_content_background.clear_rect(0, 0,
                                              background_rect.width, offset)
      @_texture_content_background.clear_rect(background_rect.width - offset, 0,
                                              offset, background_rect.height)
      @_texture_content_background.clear_rect(0, background_rect.height - offset,
                                              background_rect.width, offset)

      # window_skin
      winskin = @windowskin.texture

      # top_left
      @_texture_window_skin.render_texture(winskin,
                                           0, 0,
                                           src_x: 64, src_y: 0,
                                           src_width: 16, src_height: 16)
      # top_right
      @_texture_window_skin.render_texture(winskin,
                                           @_texture_window_skin.width - 16, 0,
                                           src_x: 128 - 16, src_y: 0,
                                           src_width: 16, src_height: 16)
      # bottom_left
      @_texture_window_skin.render_texture(winskin,
                                           0, @_texture_window_skin.height - 16,
                                           src_x: 64, src_y: 64 - 16,
                                           src_width: 16, src_height: 16)
      # bottom_right
      @_texture_window_skin.render_texture(winskin,
                                           @_texture_window_skin.width - 16,
                                           @_texture_window_skin.height - 16,
                                           src_x: 128 - 16, src_y: 64 - 16,
                                           src_width: 16, src_height: 16)
      # top
      trg_rect = Rect.new(16, 0, @_texture_window_skin.width - 32, 16)
      src_rect = Rect.new(64 + 16, 0, 32, 16)
      TextureTool.loop_texture(@_texture_window_skin, trg_rect, winskin, src_rect)
      # bottom
      trg_rect.set(trg_rect.x, @_texture_window_skin.height - 16, trg_rect.width, 16)
      src_rect.set(64 + 16, 64 - 16, 32, 16)
      TextureTool.loop_texture(@_texture_window_skin, trg_rect, winskin, src_rect)
      # left
      trg_rect.set(0, 16, 16, @_texture_window_skin.height - 32)
      src_rect.set(64, 16, 16, 32)
      TextureTool.loop_texture(@_texture_window_skin, trg_rect, winskin, src_rect)
      # right
      trg_rect.set(@_texture_window_skin.width - 16, trg_rect.y, 16, trg_rect.height)
      src_rect.set(128 - 16, 16, 16, 32)
      TextureTool.loop_texture(@_texture_window_skin, trg_rect, winskin, src_rect)
      @redrawn = true
    end

  public

    ### class_variables
    @@window_id = 0

    attr_reader :id

    def initialize(x, y, w, h)
      @x, @y, @width, @height = x.to_i, y.to_i, w.to_i, h.to_i

      @ox, @oy = 0, 0
      @z = 0

      @padding = 12
      @padding_bottom = 0

      @opacity          = 255
      @back_opacity     = 255
      @contents_opacity = 255

      @openness = 255

      @visible       = true
      @active        = true
      @arrows_visible = true
      @pause         = false

      # Custom Objects
      @tone        = Tone.new(0, 0, 0, 0)
      @cursor_rect = Rect.new(0, 0, 0, 0)
      @viewport    = nil

      # Bitmap
      @contents    = Bitmap.new(1, 1)
      @windowskin  = nil

      # Internal cursor tick
      @_cursor_ticks = 0
      @_cursor_opacity = 255

      # Internal pause tick
      @_pause_tick  = 0
      @_pause_index = 0

      @_looped_background = false
      # internal
      remake_window
      redraw_window

      # interfaces
      setup_renderable_id
      register_renderable

      @id = @@window_id
      @@window_id += 1
    end

    def dup
      raise SRRI::Error.mk_copy_error(self)
    end

    def clone
      raise SRRI::Error.mk_copy_error(self)
    end

    attr_reader :x, :y, :z, :ox, :oy, :width, :height,
                :openness, :padding, :padding_bottom,
                :opacity, :back_opacity, :contents_opacity,
                :contents, :windowskin, :viewport,
                :cursor_rect,
                :active, :arrows_visible, :pause, :visible,
                :tone

    def dispose
      @_texture_window_skin.dispose if @_texture_window_skin
      @_texture_content_background.dispose if @_texture_content_background
      @_cursor_texture.dispose if @_cursor_texture
      super
    end

    def update
      update_cursor_state
      update_pause_state
    end

    def update_pause_state
      if @pause
        @_pause_tick += 1
        @_pause_index = (@_pause_tick / 15) % 4
      end
    end

    # default
    def update_cursor_state
      if active
        @_cursor_ticks += 1
        # Pulse
        if @_cursor_ticks % 30 < 15
          @_cursor_opacity = 128 + 128 * (@_cursor_ticks % 15) / 15.0
        else
          @_cursor_opacity = 255 - 128 * (@_cursor_ticks % 15) / 15.0
        end
      else
        @_cursor_opacity = 128
      end
    end

    def open?
      @openness == 255
    end

    def close?
      @openness == 0
    end

    def windowskin=(new_windowskin)
      @windowskin = new_windowskin
    end

    def contents=(new_contents)
      @contents = new_contents
    end

    def x=(new_x)
      @x = new_x.to_i
    end

    def y=(new_y)
      @y = new_y.to_i
    end

    def z=(new_z)
      @z = new_z.to_i
      super(@z)
    end

    def ox=(new_ox)
      @ox = new_ox.to_i
    end

    def oy=(new_oy)
      @oy = new_oy.to_i
    end

    def width=(new_width)
      @width = new_width.to_i
      trash_window
    end

    def height=(new_height)
      @height = new_height.to_i
      trash_window
    end

    def cursor_rect=(new_rect)
      @cursor_rect = new_rect
    end

    def move(x, y, w, h)
      @x = x.to_i
      @y = y.to_i
      @width = w.to_i
      @height = h.to_i

      trash_window
    end

    def openness=(new_openness)
      @openness = [[new_openness.to_i, 0].max, 255].min
    end

    def tone=(new_tone)
      @tone = new_tone
    end

    def opacity=(new_opacity)
      @opacity = [[new_opacity.to_i, 0].max, 255].min
    end

    def back_opacity=(new_back_opacity)
      @back_opacity = [[new_back_opacity.to_i, 0].max, 255].min
    end

    def contents_opacity=(new_contents_opacity)
      @contents_opacity = [[new_contents_opacity.to_i, 0].max, 255].min
    end

    def padding=(new_padding)
      @padding = new_padding.to_i
    end

    def padding_bottom=(new_padding_bottom)
      @padding_bottom = new_padding_bottom.to_i
    end

    def active=(new_active)
      @active = !!new_active
    end

    def visible=(new_visible)
      @visible = !!new_visible
    end

    def arrows_visible=(new_arrows_visible)
      @arrows_visible = !!new_arrows_visible
    end

    def pause=(new_pause)
      @pause = !!new_pause
    end
  end
end
