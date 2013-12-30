#
# rm-srri/lib/module/Graphics.rb
#   dc ??/??/2012
#   dm 09/05/2013
# vr 0.7.2.001
require_relative 'graphics/canvas.rb'
require_relative 'graphics/alpha_transition.rb'

module SRRI
  module Graphics

    @canvas = SRRI::Graphics::Canvas.new(nil)

  class << self

    attr_accessor :starruby, :canvas, :display_fps

    def display_fps?
      !!@display_fps
    end

    def self.fixme(*syms)
      syms.each do |sym|
        define_method(sym) do |*args, &block|
          puts "fixme: #{self.name} #{sym}"
        end
        #module_function(sym)
      end
    end

    def __reset__
      @canvas.clear
      @frame_count = 0
    end

    def rect
      return @rect ||= SRRI::Rect.new(0, 0, width, height)
    end

    def init
      @frame_count = 0
      @canvas.texture = @starruby.screen
      @starruby.frame_rate = @frame_rate
      @fade_time, @fade_time_max = 0, 1
      @target_brightness = 255

      SRRI.try_log do |logger|
        logger.puts("SRRI | Graphics initialized")
      end
    end

    # view control
    def translate(*args, &block)
      @canvas.translate(*args, &block)
    end

    def update
      return false unless @starruby
      return false if @starruby.disposed?
      return SRRI.kill_starruby if @starruby.window_closing?
      update_fade if fading?
      # V2 Rendering
      #@starruby.update_screen do
        # V1 Rendering
        @canvas.redraw
        update_transition if @transition
      #  @canvas.render
      #end
      @starruby.update_screen # V1 Rendering
      @starruby.wait
      if display_fps?
        @starruby.title = "FPS: %-04s" % @starruby.fps.round(2)
      end
      @frame_count += 1
    end

    # Frame Tracker
    def frame_count
      @frame_count ||= 0
    end

    def frame_count=(n)
      @frame_count = n.to_i
    end

    def frame_rate
      @starruby ? @starruby.frame_rate : @frame_rate ||= 60
    end

    def frame_rate=(n)
      @frame_rate = n.to_i
      @starruby.frame_rate = @frame_rate if @starruby
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

    def resize_screen(*args)
      case args.size
      when 1
        arg, = args
        case arg
        when Array
          new_width, new_height = arg
        when Rect
          new_width, new_height = arg.to_a[2, 2]
        when Hash
          new_width, new_height = arg[:width], arg[:height]
        when StarRuby::Vector2
          new_width, new_height = arg.to_a
        end
      when 2
        new_width, new_height = *args
      end
      @width, @height = new_width.to_i, new_height.to_i
      # Trigger resize if the window is currently open
      SRRI.mk_starruby if @starruby
    end

    def snap_to_bitmap
      bmp = SRRI::Bitmap.new(width, height)
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
      update while fading?
    end

    def fadeout(frames)
      raise(ArgumentError, "frames must be greater than 0") if frames < 1
      @target_brightness = 0
      @fade_time = @fade_time_max = frames.to_i
      update while fading?
    end

    def freeze_screen
      dispose_transition
      @frozen_texture = @canvas.texture.dup
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
        #raise(TransitionError, "Cannot transition without an active @transition")
      end

      @transition_time = 0
      @transition_time_max = duration.to_i
    end

    def transition_rate
      delta = @transition_time > -1 ? @transition_time : 0.0
      delta / [@transition_time_max, 1].max.to_f
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

    ## SRRI only
    # ::fps
    def fps
      @starruby.fps
    end

  end # class << self

    def self.freeze(*args, &block)
      freeze_screen(*args, &block)
    end

  end
end
