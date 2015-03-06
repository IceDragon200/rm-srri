require 'starruby/font'

module SRRI
  class Font
    ### class-variables
    #
    @@font_cache = {}
    @@strb_size_offset = 4

    # // Instance Variable Accessors
    attrs =[
            :name,          # RGSS2/3
            :size,          # RGSS2/3
            :bold,          # RGSS2/3
            :italic,        # RGSS2/3
            :shadow,        # RGSS2/3
            :outline,       # RGSS3
            :color,         # RGSS2/3
            :out_color,     # RGSS3
            :antialias,     # SRRI
            :shadow_color,  # SRRI
            :shadow_conf,   # SRRI
            :exconfig,      # SRRI
            :underline      # SRRI
          ]
    attr_accessor *attrs

    ## RGSS2/3
    # default_*
    # default_*=
    attrs.each do |atr|
      module_eval("def self.default_#{atr}\n  @default.#{atr}\nend\n\n")
      module_eval("def self.default_#{atr}=(val)\n  @default.#{atr} = val\nend\n\n")
    end

    ##
    # initialize
    def initialize(name = nil, size = nil)
      set_default
      self.name = name if name
      self.size = size if size
    end

    def name=(new_name)
      @name = Array(new_name)
    end

    ## (SRRI)
    # set_default
    def set_default
      klass = self.class
      @name         = klass.default.name.dup
      @size         = klass.default.size
      @color        = klass.default.color.dup
      @out_color    = klass.default.out_color.dup
      @bold         = klass.default.bold
      @italic       = klass.default.italic
      @shadow       = klass.default.shadow
      @outline      = klass.default.outline
      @antialias    = klass.default.antialias
      @shadow_color = klass.default.shadow_color.dup
      @shadow_conf  = klass.default.shadow_conf.dup
      @exconfig     = klass.default.exconfig.dup
      @underline    = klass.default.underline
      self
    end
    private :set_default

    ## (SRRI)
    # is this font valid?
    def valid?
      (@name && @name.any?)
    end

    ## (SRRI)
    # to_strb_font
    def to_strb_font(fallback = false)
      font_name, = @name
      size = @size - @@strb_size_offset
      options = {
        bold: !!@bold,
        italic: !!@italic
      }
      options[:underline] = !!@underline if StarRuby::Font.method_defined?(:underline)

      args = [font_name, size, options]

      unless @@font_cache[args]
        extnm = File.extname(font_name)
        bs_fontname = File.basename(font_name, extnm)

        abs_fontname = nil
        for ext in [extnm, *SRRI::Font.font_ext].compact
          break if abs_fontname = SRRI::Font.search_font(bs_fontname, ext)
        end

        return unless abs_fontname
        args = [abs_fontname, size, options]

        retry_count = 0

        begin
          @@font_cache[args] = StarRuby::Font.new(*args)
        rescue StarRuby::StarRubyError => ex
          retry_count += 1
          if retry_count < 3
            retry;
          else
            if fallback
              @@font_cache[args] = Font.default.to_strb_font(true)
              SRRI.try_log do |l|
                l.puts("Font conversion failed with args (#{args.inspect})")
                l.puts("Exception: #{ex.inspect}")
                l.puts("Backtrace:\n#{ex.backtrace.join("\n")}")
              end
            else
              raise ex
            end
          end
        end
      end

      return @@font_cache[args]
    end

    ## 1.3.1
    # text_size(String str) -> Array<Integer>[:width, :height]
    def text_size(str)
      to_strb_font.get_size(str.to_s)
    end

    ### Class Functions
    ## (SRRI)
    # ::clear_cache
    def self.clear_cache
      @@font_cache.clear
    end

    ##
    # ::get_cache -> Hash<Array[], StarRuby::Font>
    def self.get_cache
      @@font_cache
    end

    ## (SRRI)
    # ::search_font
    def self.search_font(fontname, ext)
      @font_path.each do |basepath|
        path = File.join(basepath, fontname + ext)
        return path if File.exist?(path)
      end
      return nil
    end

    ## (SRRI)
    # ::init
    def self.init
      @default = allocate
      # // Array or String
      @default.name      = ['VL-Gothic-Regular.ttf']
      @default.size      = 20
      # Color
      @default.color     = Color.new( 255, 255, 255, 255) # // RGSS2
      @default.out_color = Color.new(   0,   0,   0, 128) # // RGSS3

      # // Booleans
      @default.bold      = false
      @default.italic    = false
      @default.shadow    = false # // RGSS2
      @default.outline   = false # // RGSS3

      @default.shadow_color = Color.new(0, 0, 0, 255) # // YGG1x6+

      # // SRRI
      @default.antialias = true
      @default.shadow_conf = [1, 2] # [anchor, distance]
      @default.exconfig = {
        flip_shadow_color: false,
        flip_outline_color: false
      }
      @default.underline = false

      @font_path = [File.expand_path("fonts"), File.expand_path("Fonts")]
      @font_ext  = ['.ttf', '.TTF']

      SRRI.try_log do |logger|
        logger.puts("Font initialized\n  Font Paths: #@font_path\n  Checking Extensions: #@font_ext")
      end
    end

    ## (SRRI)
    # ::default
    def self.default
      @default
    end

    ## (SRRI)
    # ::default=(Font new_default)
    def self.default=(new_default)
      @default = new_default
    end

    ## (SRRI)
    # ::font_path
    def self.font_path
      @font_path
    end

    ## (SRRI)
    # ::font_path=(Array<String> new_font_path)
    def self.font_path=(new_font_path)
      @font_path = new_font_path
    end

    ## (SRRI)
    # ::font_ext
    def self.font_ext
      @font_ext
    end

    ## (SRRI)
    # ::font_ext=(Array<String> new_font_ext)
    def self.font_ext=(new_font_ext)
      @font_ext = new_font_ext
    end

    def self.exist?(filename)
      true
    end
  end
end
