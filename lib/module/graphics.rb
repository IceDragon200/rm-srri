#
# src/module/graphics.rb
#
# vr 0.70
require_relative 'graphics/canvas.rb'

module Graphics

class << self

  attr_accessor :starruby, :canvas

  def self.fixme(*syms)
    syms.each do |sym|
      define_method(sym) do
        |*args, &block|
        puts "fixme: #{self.name} #{sym}"
      end
      #module_function(sym)
    end
  end

  def _reset
    @canvas.drawable.each(&:dispose)
    @canvas.drawable.clear
    @frame_count = 0
  end

  def rect
    return @rect ||= Rect.new(0, 0, width, height)
  end

  def init
    @frame_count = 0
    @canvas = Canvas.new(@starruby.screen)

    @fade_time, @fade_time_max = 0, 1
    @target_brightness = 255
  end

  # view control
  def translate(*args, &block)
    @canvas.translate(*args, &block)
  end

  def update
    return unless @starruby

    if @starruby.window_closing? and !@starruby.disposed?
      @starruby.dispose
      exit
      return
    end

    update_fade if fading?

    @canvas.redraw

    if @frozen_texture
      @canvas.texture.render_texture(@frozen_texture, 0, 0,
        alpha: 255.0 * @transition_time / @transition_time_max.to_f)
      @transition_time -= 1
      (@frozen_texture.dispose; @frozen_texture = nil) if @transition_time < 1
    end

    @frame_count += 1

    @sr_font ||= Font.new.to_starruby_font
    @sr_color ||= Font.new.color.to_starruby_color

    @starruby.screen.render_text(
      "FPS: %-04s" % @starruby.real_fps.round(2), 0, 0, @sr_font, @sr_color, true
    )

    @starruby.update_screen
    @starruby.wait
  end

  # Frame Tracker
  def frame_count
    return @frame_count
  end

  def frame_count=(n)
    @frame_count = n.to_i
  end

  def frame_rate
    @starruby ? @starruby.fps : @fps
  end

  def frame_rate=(n)
    @fps = n.to_i
    @starruby.fps = @fps if @starruby
  end

  # Canvas
  def width
    @width ||= RGX::DEFAULT_WIDTH
  end

  def height
    @height ||= RGX::DEFAULT_HEIGHT
  end

  def brightness
    @canvas.opacity
  end

  def brightness=(n)
    @canvas.opacity = n
  end

  fixme(:play_movie, :frame_reset)

  def resize_screen(new_width, new_height)
    @width, @height = new_width.to_i, new_height.to_i
    # Trigger resize if the window is currently open
    Game.mk_starruby() if @starruby
  end

  def snap_to_bitmap
    bmp = Bitmap.new(width, height)
    bmp.texture.render_texture(@canvas.texture, 0, 0)
    bmp
  end

  def wait(frames)
    frames.times do
      update
    end
  end

  def fadein(frames)
    raise(ArgumentError, "frames must be greater than 0") if frames < 1
    @target_brightness = 255
    @fade_time = @fade_time_max = frames.to_i
  end

  def fadeout(frames)
    raise(ArgumentError, "frames must be greater than 0") if frames < 1
    @target_brightness = 0
    @fade_time = @fade_time_max = frames.to_i
  end

  def freeze
    @frozen_texture.dispose if @freeze_texture
    @frozen_texture = @canvas.texture.clone

    @transition_time = 0
    @transition_time_max = 1
  end

  def transition(*args)
    filename = nil
    vague = nil
    case args.size
    # duration
    when 1
      duration, = *args
    # duration, filename
    when 2
      puts "fixme: Graphics.transition(duration, filename)"
      duration, filename = *args
    # duration, filename, vague
    when 3
      puts "fixme: Graphics.transition(duration, filename, vague)"
      duration, filename, vague = *args
    end

    @transition_time = @transition_time_max = duration.to_i

    # if the transition time is 0 (instant) just dispose the texture
    (@frozen_texture.dispose; @frozen_texture = nil) if @transition_time_max < 1
  end

private

  def transition?
    return @transition_time > 0
  end

  def fading?
    return @fade_time > 0
  end

  def update_fade
    n = 255.0 / @fade_time
    n = -n if @target_brightness < brightness
    self.brightness += n
    @fade_time -= 1
  end

end # class << self

end
