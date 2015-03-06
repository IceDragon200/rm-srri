require 'starruby'
require '../lib/srri'

## SOLVED -
rgss_main do
  Graphics.resize_screen(800, 600)  # bug here
  loop do
    Graphics.update
  end
end
