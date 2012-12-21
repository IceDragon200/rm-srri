require_relative '../../local.rb'

rgss_main do
  sp = Sprite.new
  sp.bitmap = Bitmap.new(32, 32)
  sp.bitmap.fill_rect(sp.bitmap.rect, Color.new(255, 255, 255, 255))

  loop do
    Graphics.update
    Input.update
    case Input.dir8
    when 1
      sp.x -= 1
      sp.y += 1
    when 2
      sp.y += 1
    when 3
      sp.x += 1
      sp.y += 1
    when 4
      sp.x -= 1
    when 5

    when 6
      sp.x += 1
    when 7
      sp.x -= 1
      sp.y -= 1
    when 8
      sp.y -= 1
    when 9
      sp.x += 1
      sp.y -= 1
    end
  end
end
