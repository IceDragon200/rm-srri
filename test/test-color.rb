require '../local.rb'
# Empty Color Initialize
p Color.new()

# RGB Color Initialize
p Color.new(244, 128, 90)

# RGBA Color Initialize
p Color.new(129, 80, 24, 200)

# Color Modification
p color = Color.new(0, 0, 0, 0)
color.red   = 255
color.green = 155
color.blue  = 55
color.alpha = 255

puts color

# Color Duplication
p color1 = color.dup
p color2 = color1.clone

# OOR Tests
p color = Color.new()
color.red = -10
color.green = 480
color.blue = 0xFFF
color.alpha = -255

p color
