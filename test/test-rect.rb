require '../local.rb'
# Empty Rect Initialize
p Rect.new()

# x, y, width, height Rect Initialize
p Rect.new(0, 0, 256, 256)

# Rect Rect Initialize
p Rect.new(Rect.new(0, 0, 32, 32))

# Rect Modification
p rect = Rect.new(0, 0, 0, 0)
rect.x      = 32
rect.y      = 32
rect.width  = 64
rect.height = 64

puts rect

# Rect Duplication
p rect1 = rect.dup
p rect2 = rect1.clone
