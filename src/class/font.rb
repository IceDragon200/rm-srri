class RGX::Font

  # // Class Variable Accessors
class << self
  attr_accessor :default_name, :default_size  , 
                :default_color , :default_out_color,
                :default_bold, :default_italic, 
                :default_shadow, :default_outline,
                :default_antialias, :default_shadow_color
end

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

  @default_antialias = true  # // RGX
  @default_shadow_color = Color.new(0, 0, 0, 255)

  # // Instance Variable Accessors 
  attr_accessor :name, :size, 
                :bold, :italic, :shadow, :outline, 
                :out_color, :color,
                :antialias, :shadow_color

  def initialize
    klass    = self.class
    
    @name      = klass.default_name
    @size      = klass.default_size
    @color     = klass.default_color
    @out_color = klass.default_out_color

    @bold      = klass.default_bold
    @italic    = klass.default_italic
    @shadow    = klass.default_shadow
    @outline   = klass.default_outline

    @antialias = klass.default_antialias
    @shadow_color = klass.default_shadow_color
  end

  def to_starruby_font
    font_name, = @name
    ext = File.extname(font_name)
    ext = ".ttf" if ext.nil? or ext.empty?

    name = "./fonts/#{File.basename(font_name, ext)}#{ext}"
    size = @size - 3
    hash = {
      bold: !!@bold,
      italic: !!@italic
    }

    return StarRuby::Font.new(name, size, hash)
  end

end
