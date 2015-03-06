require 'starruby/color'

module SRRI
  class Color < StarRuby::Color
    def initialize(*args)
      if args.empty?
        super 0, 0, 0, 0
      else
        super
      end
    end
  end
end
