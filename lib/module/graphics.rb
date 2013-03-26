#
# rm-srri/lib/module/graphics.rb
# vr 0.7.2
require_relative 'graphics/canvas.rb'

module Graphics

class AlphaTransition

  def self.transition(target, t1, t2, delta)
    StarRuby::Transition.crossfade(target, t1, t2, delta)
    #TextureTool.render_texture_fast(target, 0, 0,
    #                                t1, 0, 0, t1.width, t1.height,
    #                                255 - delta, nil, nil, 0) if t1 != target
    #TextureTool.render_texture_fast(target, 0, 0,
    #                                t2, 0, 0, t2.width, t2.height,
    #                                delta, nil, nil, 1)
  end

  def self.dispose
    return
  end

end

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
    end

    update_fade if fading?

    @canvas.redraw

    update_transition if @transition

    @frame_count += 1

    #@sr_font ||= Font.new.to_strb_font
    #@sr_color ||= Font.new.color.to_strb_color

    #@starruby.screen.render_text(
    #  "FPS: %-04s" % @starruby.real_fps.round(2), 0, 0, @sr_font, @sr_color, true
    #)
    @starruby.title = "FPS: %-04s" % @starruby.real_fps.round(2)
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
    @width ||= SRRI::DEFAULT_WIDTH
  end

  def height
    @height ||= SRRI::DEFAULT_HEIGHT
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

  def freeze_screen
    dispose_transition
    @frozen_texture = @canvas.texture.clone
    @transition = AlphaTransition #@frozen_texture.to_transition

    @transition_time = -1
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

    unless @transition
      return
      #raise(StandardError, "Cannot transition without an active @transition")
    end

    @transition_time = 0
    @transition_time_max = duration.to_i
  end

  def transition_rate
    delta = @transition_time > -1 ? @transition_time : 0.0
    delta / @transition_time_max.to_f
  end

  def update_transition
    delta = transition_rate
    t0 = @canvas.texture
    t1 = @frozen_texture
    t2 = @canvas.texture
    #t2 = @canvas.texture.dup

    #t0.clear
    @transition.transition(t0, t1, t2, 0xFF * delta)
    #t2.dispose

    return if @transition_time == -1

    @transition_time += 1

    dispose_transition if @transition_time >= @transition_time_max
  end

  def dispose_transition
    @frozen_texture.dispose if @freeze_texture
    @transition.dispose if @transition
    @frozen_texture = nil
    @transition = nil
  end

  def frozen_screen?
    !!@frozen_texture
  end

  def transition?
    @transition_time > 0
  end

  def fading?
    @fade_time > 0
  end

  def update_fade
    n = 255.0 / @fade_time
    n = -n if @target_brightness < brightness
    self.brightness += n
    @fade_time -= 1
  end

end # class << self

  def self.freeze(*args, &block)
    freeze_screen(*args, &block)
  end

end
