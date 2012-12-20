module SRRI

  def self.init
    Graphics.init
    Audio.init
    Input.init
  end

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
      fullscreen: @@config[:fullscreen]
    )
    Graphics.starruby = game
  end

end
