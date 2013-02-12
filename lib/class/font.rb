class RGX::Font

  def to_starruby_font
    font_name, = @name
    ext = File.extname(font_name)
    ext = ".ttf" if ext.nil? or ext.empty?

    size = @size - 3
    hash = {
      bold: !!@bold,
      italic: !!@italic
    }

    name = "./fonts/#{File.basename(font_name, ext)}#{ext}"
    return StarRuby::Font.new(name, size, hash)
  end

end
