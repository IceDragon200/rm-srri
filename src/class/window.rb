#
# src/class/window.rb
#
# vr 0.80

##
# RGX::Window
#
class RGX::Window

  def dup
    raise(StandardError, "Cannot #dup #{self}")
  end

  def clone
    raise(StandardError, "Cannot #clone #{self}")
  end

  include Interface::IDrawable
  include Interface::IDisposable
  include Interface::IZSortable

  def draw(texture)
    return unless @visible
    return if @width == 0
    return if @height == 0

    unless @redrawn
      puts "Redrawing: #{self}"
      remake_window
      redraw_window
    end

    view = (viewport || Graphics)

    view.translate(@x, @y) do |vx, vy|
      pad, pad2 = @padding, @padding * 2

      arra = [vx, vy, @width, @height]

      draw_content_background(texture, *arra)
      draw_window_skin(texture, *arra)

      return if @openness < 255
      draw_cursor(texture,
        vx + pad + @cursor_rect.x, vy + pad + @cursor_rect.y,
        @width - pad2, @height - pad2
      ) unless @cursor_rect.empty?

      draw_content(
        texture,
        vx + pad, vy + pad, @width - pad2, @height - pad2
      ) if @contents and !@contents.disposed?

    end
  end

private

  def draw_content_background(texture, x, y, w, h)
    cw = [w, @_texture_content_background.width].min
    ch = [h, @_texture_content_background.height].min

    ay = 0
    scale = @openness / 255.0
    ay = ((h / 2.0) * (1 - scale)).to_i if scale != 1.0

    texture.render_texture(
      @_texture_content_background, x, y + ay,
      src_width: cw, src_height: ch,
      tone_red: @tone.red, tone_green: @tone.green, tone_blue: @tone.blue,
      saturation: 255 - @tone.grey,
      alpha: @back_opacity * @opacity / 255.0,
      scale_y: @openness / 255.0
    )
  end

  def draw_window_skin(texture, x, y, w, h)
    ay = 0
    scale = @openness / 255.0
    ay = ((h / 2.0) * (1 - scale)).to_i if scale != 1.0

    texture.render_texture(
      @_texture_window_skin, x, y + ay,
      alpha: @opacity,
      scale_y: scale
    )
  end

  def draw_cursor(texture, x, y, w, h)
    return false if @cursor_rect.empty?

    if @_cursor_texture and (@cursor_rect.width != @_cursor_texture.width or
     @cursor_rect.height != @_cursor_texture.height)
      @_cursor_texture.dispose
      @_cursor_texture = nil
    end

    unless @_cursor_texture
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

    texture.render_texture(
      @_cursor_texture, x - @ox, y - @oy, alpha: @_cursor_opacity)
  end

  def draw_content(texture, x, y, w, h)
    cw = [w, @contents.width].min
    ch = [h, @contents.height].min

    # cropping
      #dx = vrect.x - rx
      #dy = vrect.y - ry
      #dw = (rx + sw) - (vrect.x + vrect.width)
      #dh = (ry + sh) - (vrect.y + vrect.height)

      #(rx += dx; sx += dx; sw -= dx) if dx > 0
      #(ry += dy; sy += dy; sh -= dy) if dy > 0
      #sw -= dw if dw > 0
      #sh -= dh if dh > 0

    texture.render_texture(
      @contents.texture, x, y,
      src_x: @ox, src_y: @oy, src_width: cw, src_height: ch,
      alpha: @contents_opacity
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

  def initialize(x, y, w, h)
    # Internal
    @_looped_background = false
    @_cursor_opacity = 255
    @_frames = 0

    #
    _set_size(x, y, w, h)

    @ox, @oy = 0, 0
    @z = 0

    @padding = 12
    @padding_bottom = 0

    @opacity          = 255
    @back_opacity     = 198 #255
    @contents_opacity = 255

    @openness = 255

    @visible       = true
    @active        = true
    @arrows_visible = true
    @pause         = false

    # Custom Objects
    @tone        = RGX::Tone.new(0, 0, 0, 0)
    @cursor_rect = RGX::Rect.new()
    @viewport    = nil

    # Bitmap
    @contents    = RGX::Bitmap.new(1, 1)
    @windowskin  = nil

    remake_window
    redraw_window
    register_drawable
    setup_iz_id
  end

public

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
    unregister_drawable
    super
  end

  def update
    if @active
      @_frames += 1
      #@_cursor_opacity = @_frames % 30 <= 15 ? 255 : 128 # Flicker
      if @_frames % 30 < 15
        @_cursor_opacity = 128 + 128 * (@_frames % 15) / 15.0
      else
        @_cursor_opacity = 255 - 128 * (@_frames % 15) / 15.0
      end
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
    @width = new_width
    trash_window
  end

  def height=(new_height)
    @height = new_height
    trash_window
  end

  def viewport=(new_viewport)
    @viewport = new_viewport
    super(@viewport)
  end

  def cursor_rect=(new_rect)
    @cursor_rect = new_rect
  end

  def _set_size(x, y, w, h)
    @x      = x.to_i
    @y      = y.to_i
    @width  = w.to_i
    @height = h.to_i
  end

  def move(x, y, w, h)
    _set_size(x, y, w, h)
    trash_window
  end

  def openness=(new_openness)
    @openness = [[0, new_openness.to_i].max, 255].min
  end

  def tone=(new_tone)
    @tone = new_tone
  end

  def opacity=(new_opacity)
    @opacity = new_opacity.to_i
  end

  def back_opacity=(new_back_opacity)
    @back_opacity = new_back_opacity.to_i
  end

  def contents_opacity=(new_contents_opacity)
    @contents_opacity = new_contents_opacity.to_i
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

end
