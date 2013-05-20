#
# rm-srri/lib/class/Font.rb
#   by IceDragon
#   dc ??/??/2012
#   dm 12/05/2013
# vr 1.3.0
module SRRI
  class Font

    ### class-variables
    #
    @@font_cache = {}
    @@strb_size_offset = 3

    # // Instance Variable Accessors
    attrs =[
            :name,          # RGSS2/3
            :size,          # RGSS2/3
            :bold,          # RGSS2/3
            :italic,        # RGSS2/3
            :shadow,        # RGSS2/3
            :outline,       # RGSS3
            :out_color,     # RGSS3
            :color,         # RGSS2/3
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
    def initialize
      default!
    end

    ## (SRRI)
    # default!
    def default!
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

    ## (SRRI)
    # default
    def default
      dup.default!
    end

    ## (SRRI)
    # to_strb_font
    def to_strb_font
      font_name, = @name
      size = @size - @@strb_size_offset
      options = {
        bold: !!@bold,
        italic: !!@italic,
        underline: !!@underline
      }

      args = [font_name, size, options]

      unless @@font_cache[args]
        extnm = File.extname(font_name)
        bs_fontname = File.basename(font_name, extnm)

        abs_fontname = nil
        for ext in [extnm, *SRRI::Font.font_exts].compact
          break if abs_fontname = SRRI::Font.search_font(bs_fontname, ext)
        end

        args = [abs_fontname, size, options]

        @@font_cache[args] = StarRuby::Font.new(*args)
      end

      return @@font_cache[args]
    end

    ### Class Functions
    ## (SRRI)
    # ::clear_cache
    def self.clear_cache
      @@font_cache.clear
    end

    ## (SRRI)
    # ::search_font
    def self.search_font(fontname, ext)
      @font_paths.each do |basepath|
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
      @default.name      = ['ProggySmall.ttf']
      @default.size      = 20
      # Color
      @default.color     = Color.new( 255, 255, 255, 255) # // RGSS2
      @default.out_color = Color.new(  24,  24,  24,  96) # // RGSS3

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

      @font_paths = ["fonts", "Fonts"]
      @font_exts  = ['.ttf', '.TTF']

      SRRI.try_log do |logger|
        logger.puts("Font initialized\n  Font Paths: #@font_paths\n  Checking Extensions: #@font_exts")
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
    # ::font_paths
    def self.font_paths
      @font_paths
    end

    ## (SRRI)
    # ::font_paths=(Array<String> new_font_paths)
    def self.font_paths=(new_font_paths)
      @font_paths = new_font_paths
    end

    ## (SRRI)
    # ::font_exts
    def self.font_exts
      @font_exts
    end

    ## (SRRI)
    # ::font_exts=(Array<String> new_font_exts)
    def self.font_exts=(new_font_exts)
      @font_exts = new_font_exts
    end

  end
end
