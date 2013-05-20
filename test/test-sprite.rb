require_relative '../local.rb'

rgss_main do
  sp_background = Sprite.new(nil)
  sp_background.bitmap = Bitmap.new(Graphics.width, Graphics.height)
  sp_background.bitmap.fill_rect(
    0, 0, Graphics.width, Graphics.height, Color.new(255, 255, 255, 255))

  sp = Sprite.new
  bmp = sp.bitmap = Bitmap.new(Graphics.width, 24)
  sp.bitmap.fill_rect(0, 0, bmp.width, bmp.height, Color.new(0, 0, 98, 255))
  sp.y = 48

  viewport = Viewport.new(32, 32, 64, 64)
  sp2 = Sprite.new
  bmp = sp2.bitmap = Bitmap.new(256, 256)
  sp2.bitmap.fill_rect(
    0, 0, bmp.width, bmp.height, Color.new(24, 28, 26, 198))
  sp2.viewport = viewport


  @time_before = 0.0
  @fps = 60.0
  loop do
    Graphics.update
    Input.update
    n = Time.now.to_f
    @fps = (1 / (n - @time_before)) if Graphics.frame_count % Graphics.frame_rate == 0 #* frame_rate #(1 - (n - @time_before)) * frame_rate
    @time_before = n

    Graphics.starruby.title = "Game: FPS #{@fps.round(0)}"
  end
end
