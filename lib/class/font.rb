#
# rm-srri/lib/class/font.rb
# vr 1.1.0
class SRRI::Font

  # // Class Variable Accessors
class << self
  attr_accessor :default_name, :default_size  ,
                :default_color , :default_out_color,
                :default_bold, :default_italic,
                :default_shadow, :default_outline,
                :default_antialias, :default_shadow_color,
                :default_shadow_conf, :default_exconfig
end

  def self.init
    # // Array or String
    @default_name      = ['ProggySmall.ttf']
    @default_size      = 20
    @default_color     = Color.new( 255, 255, 255, 255) # // RGSS2
    @default_out_color = Color.new(  24,  24,  24,  96) # // RGSS3

    # // Booleans
    @default_bold      = false
    @default_italic    = false
    @default_shadow    = false # // RGSS2
    @default_outline   = false # // RGSS3

    @default_shadow_color = Color.new(0, 0, 0, 255) # // YGG1x6

    # // SRRI
    @default_antialias = true
    @default_shadow_conf = [1, 2] # [anchor, distance]
    @default_exconfig = {
      flip_shadow_color: false,
      flip_outline_color: false
    }
  end

  @@font_cache = {}
  @@strb_size_offset = 3

  # // Instance Variable Accessors
  attr_accessor :name, :size,
                :bold, :italic, :shadow, :outline,
                :out_color, :color,
                :antialias, :shadow_color,
                :shadow_conf, :exconfig

  def initialize
    klass    = self.class

    @name      = klass.default_name.clone
    @size      = klass.default_size
    @color     = klass.default_color.clone
    @out_color = klass.default_out_color.clone

    @bold      = klass.default_bold
    @italic    = klass.default_italic
    @shadow    = klass.default_shadow
    @outline   = klass.default_outline

    @antialias = klass.default_antialias
    @shadow_color = klass.default_shadow_color.clone

    @shadow_conf = klass.default_shadow_conf.clone

    @exconfig = klass.default_exconfig.clone
  end

  def to_strb_font
    font_name, = @name
    ext = File.extname(font_name)
    ext = ".ttf" if ext.nil? or ext.empty?

    size = @size - @@strb_size_offset
    hash = {
      bold: !!@bold,
      italic: !!@italic
    }
    name = "./fonts/#{File.basename(font_name, ext)}#{ext}"

    args = [name, size, hash]
    return @@font_cache[args] ||= StarRuby::Font.new(*args)
  end

end
