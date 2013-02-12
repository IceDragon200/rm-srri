module RGX

  class Color

  # Addon
    def as_hash
      {
        red: red,
        green: green,
        blue: blue,
        alpha: alpha
      }
    end

    def to_rgx_color
      RGX::Color.new(red, green, blue, alpha)
    end

    def to_starruby_color
      StarRuby::Color.new(red, green, blue, alpha)
    end

  end

end

module StarRuby

  class Color

    def as_ary
      return [red, green, blue, alpha]
    end

    def to_rgx_color
      RGX::Color.new(red, green, blue, alpha)
    end

    def to_starruby_color
      StarRuby::Color.new(red, green, blue, alpha)
    end

  end

end
