#
# src/class/window.rb
#
# vr 0.83

##
# RGX::Window
#
class RGX::Window

  include Interface::IDrawable
  include Interface::IDisposable
  include Interface::IZSortable

  def draw(texture)
    return false if @disposed
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
      tr, tg, tb, ta = @tone.as_ary
      ay, ax = 0, 0
      #scale_x = @openness / 255.0
      scale_x = 1.0
      scale_y = @openness / 255.0
      #ax = ((@width / 2.0) * (1 - scale_x)).to_i if scale_x != 1.0
      ay = ((@height / 2.0) * (1 - scale_y)).to_i if scale_y != 1.0

      no_scale = (scale_x == 1.0 and scale_y == 1.0)

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
          alpha: @back_opacity * (@opacity / 255.0),
          scale_x: scale_x, scale_y: scale_y
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
        if no_scale
          TextureTool.render_texture_fast(
            texture, dx, dy,
            @_texture_window_skin,
            sx, sy, sw, sh,
            @opacity, 1
          )
        else
          texture.render_texture(
            @_texture_window_skin, dx, dy,
            src_x: sx, src_y: sy, src_width: sw, src_height: sh,
            alpha: @opacity,
            scale_x: scale_x, scale_y: scale_y
          )
        end
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

        TextureTool.render_texture_fast(
          texture, cdx, cdy,
          @_cursor_texture,
          0, 0, @_cursor_texture.width, @_cursor_texture.height,
          @_cursor_opacity, 1
        )
      end

      return unless @contents and !@contents.disposed?

      dx += pad
      dy += pad

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

      if no_scale
        TextureTool.render_texture_fast(
          texture, dx, dy,
          @contents.texture,
          sx, sy, sw, sh,
          @contents_opacity, 1
        )
      else
        texture.render_texture(
          @contents.texture, dx, dy,
          src_x: sx, src_y: sy, src_width: sw, src_height: sh,
          alpha: @contents_opacity,
          # RGX Behaviour
          scale_x: scale_x, scale_y: scale_y
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

    dprops = {
      src_x: 64, src_y: 64, src_width: 8, src_height: 8
    }

    props = dprops.dup

    # top-left
    @_cursor_texture.render_texture(src_texture, 0, 0, props)

    # top-right
    props[:src_x] += 24
    @_cursor_texture.render_texture(src_texture, cw - 8, 0, props)

    # top
    TextureTool.loop_texture(
      @_cursor_texture, Rect.new(8, 0, cw - 16, 8),
      src_texture, Rect.new(64 + 8, 64, 16, 8)
    )

    # mid-left
    TextureTool.loop_texture(
      @_cursor_texture, Rect.new(0, 8, 8, ch - 16),
      src_texture, Rect.new(64, 64 + 8, 8, 16)
    )

    # mid-right
    TextureTool.loop_texture(
      @_cursor_texture, Rect.new(cw - 8, 8, 8, ch - 16),
      src_texture, Rect.new(64 + 24, 64 + 8, 8, 16)
    )

    # mid
    TextureTool.loop_texture(
      @_cursor_texture, Rect.new(8, 8, cw - 16, ch - 16),
      src_texture, Rect.new(64 + 8, 64 + 8, 16, 16)
    )

    props = dprops.dup

    props[:src_y] += 24

    # bottom-left
    @_cursor_texture.render_texture(src_texture, 0, ch - 8, props)

    # bottom-right
    props[:src_x] += 24
    @_cursor_texture.render_texture(src_texture, cw - 8, ch - 8, props)

    # bottom
    TextureTool.loop_texture(
      @_cursor_texture, Rect.new(8, ch - 8, cw - 16, 8),
      src_texture, Rect.new(64 + 8, 64 + 24, 16, 8)
    )
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

    if @_looped_background
      TextureTool.loop_texture(
        @_texture_content_background, @_texture_content_background.rect,
        @windowskin.texture, Rect.new(0, 0, 64, 64)
      )
    else
      @_texture_content_background.render_texture(
        @windowskin.texture, 0, 0,
        src_x: 0, src_y: 0, src_width: 64, src_height:64,
        scale_x: @width / 60.0, scale_y: @height / 60.0
      )
    end

    TextureTool.loop_texture(
      @_texture_content_background, @_texture_content_background.rect,
      @windowskin.texture, Rect.new(0, 64, 64, 64)
    )

    # window_skin
    winskin = @windowskin.texture

    # top_left
    @_texture_window_skin.render_texture(
      winskin,
      0, 0,
      src_x: 64, src_y: 0, src_width: 16, src_height: 16
    )

    # top_right
    @_texture_window_skin.render_texture(
      winskin,
      @_texture_window_skin.width - 16, 0,
      src_x: 128 - 16, src_y: 0, src_width: 16, src_height: 16
    )

    # bottom_left
    @_texture_window_skin.render_texture(
      winskin,
      0, @_texture_window_skin.height - 16,
      src_x: 64, src_y: 64 - 16, src_width: 16, src_height: 16
    )

    # bottom_right
    @_texture_window_skin.render_texture(
      winskin,
      @_texture_window_skin.width - 16, @_texture_window_skin.height - 16,
      src_x: 128 - 16, src_y: 64 - 16, src_width: 16, src_height: 16
    )

    # top
    trg_rect = Rect.new(16, 0, @_texture_window_skin.width - 32, 16)
    src_rect = Rect.new(64 + 16, 0, 32, 16)

    TextureTool.loop_texture(
      @_texture_window_skin, trg_rect,
      winskin, src_rect
    )

    # bottom
    trg_rect.set(trg_rect.x, @_texture_window_skin.height - 16,
      trg_rect.width, 16)
    src_rect.set(64 + 16, 64 - 16, 32, 16)

    TextureTool.loop_texture(
      @_texture_window_skin, trg_rect,
      winskin, src_rect
    )

    # left
    trg_rect.set(0, 16, 16, @_texture_window_skin.height - 32)
    src_rect.set(64, 16, 16, 32)

    TextureTool.loop_texture(
      @_texture_window_skin, trg_rect,
      winskin, src_rect
    )

    # right
    trg_rect.set(
      @_texture_window_skin.width - 16, trg_rect.y, 16, trg_rect.height)
    src_rect.set(128 - 16, 16, 16, 32)

    TextureTool.loop_texture(
      @_texture_window_skin, trg_rect,
      winskin, src_rect
    )

    @redrawn = true
  end

public

  alias :rgx_initialize :initialize
  def initialize(*args, &block)
    # internal
    @_looped_background = false

    # alias
    rgx_initialize(*args, &block)

    # internal
    remake_window
    redraw_window

    # interfaces
    register_drawable
    setup_iz_id
  end

  alias :rgx_dispose :dispose
  def dispose
    @_texture_window_skin.dispose if @_texture_window_skin
    @_texture_content_background.dispose if @_texture_content_background
    @_cursor_texture.dispose if @_cursor_texture

    unregister_drawable

    rgx_dispose()
  end

  alias :rgx_move :move
  def move(*args, &block)
    rgx_move(*args, &block)
    trash_window()
  end

  def z=(new_z)
    @z = new_z.to_i
    super(@z)
  end

  def width=(new_width)
    @width = new_width
    trash_window()
  end

  def height=(new_height)
    @height = new_height
    trash_window()
  end

  def viewport=(new_viewport)
    @viewport = new_viewport
    super(@viewport)
  end

end
