#
# rm-srri/lib/class/font.rb
#   dc ??/??/2012
#   dm 20/04/2013
# vr 1.2.0
class SRRI::Font

  # // Class Variable Accessors
class << self
  attr_accessor :default_name, :default_size  ,
                :default_color , :default_out_color,
                :default_bold, :default_italic,
                :default_shadow, :default_outline,
                :default_antialias, :default_shadow_color,
                :default_shadow_conf, :default_exconfig,
                :default_underline

  attr_accessor :font_paths, :font_exts
end

  @@font_cache = {}
  @@strb_size_offset = 3

  # // Instance Variable Accessors
  attr_accessor :name, :size,
                :bold, :italic, :shadow, :outline,
                :out_color, :color,
                :antialias, :shadow_color,
                :shadow_conf, :exconfig, :underline

  def initialize
    klass    = self.class

    @name      = klass.default_name.dup
    @size      = klass.default_size
    @color     = klass.default_color.dup
    @out_color = klass.default_out_color.dup

    @bold      = klass.default_bold
    @italic    = klass.default_italic
    @shadow    = klass.default_shadow
    @outline   = klass.default_outline

    @antialias = klass.default_antialias
    @shadow_color = klass.default_shadow_color.dup

    @shadow_conf = klass.default_shadow_conf.dup

    @exconfig = klass.default_exconfig.dup

    @underline = klass.default_underline
  end

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

  def self.clear_cache
    @@font_cache.clear
  end

  def self.search_font(fontname, ext)
    @font_paths.each do |basepath|
      path = File.join(basepath, fontname + ext)
      return path if File.exist?(path)
    end
    return nil
  end

  def self.init
    # // Array or String
    @default_name      = ['ProggySmall.ttf']
    @default_size      = 20
    # Color
    @default_color     = Color.new( 255, 255, 255, 255) # // RGSS2
    @default_out_color = Color.new(  24,  24,  24,  96) # // RGSS3

    # // Booleans
    @default_bold      = false
    @default_italic    = false
    @default_shadow    = false # // RGSS2
    @default_outline   = false # // RGSS3

    @default_shadow_color = Color.new(0, 0, 0, 255) # // YGG1x6+

    # // SRRI
    @default_antialias = true
    @default_shadow_conf = [1, 2] # [anchor, distance]
    @default_exconfig = {
      flip_shadow_color: false,
      flip_outline_color: false
    }
    @default_underline = false

    @font_paths = ["fonts", "Fonts"]
    @font_exts  = ['.ttf', '.TTF']
  end

end
