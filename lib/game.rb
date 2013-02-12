# StarRuby Patch
class Numeric

  alias :to_radian :degree

  remove_method :degree
  remove_method :degrees

end

class Game

  @@config = {
    cursor: false,
    frame_rate: 60,
    title: "Game",
    fullscreen: false
  }

  def self.mk_starruby()
    Graphics.starruby.close_window if Graphics.starruby
    game = StarRuby::Game.new(
      Graphics.width,
      Graphics.height,
      cursor:     @@config[:cursor],
      fps:        @@config[:frame_rate],
      title:      @@config[:title],
      fullscreen: @@config[:fullscreen],
      vsync: @@config[:vsync]
    )

    Graphics.starruby = game
  end

end
