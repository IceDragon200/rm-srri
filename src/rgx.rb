#
# rgx3.rb
#

# Main Extension Shared Library
require_relative 'ext/symbols.rb'

require_relative 'ext/rgx.so'

require_relative 'ext/table.rb'
require_relative 'ext/rect.rb'

require_relative 'ext/color.rb'
require_relative 'ext/tone.rb'

require_relative 'ext/font.rb'

require_relative 'ext/bitmap.rb'

require_relative 'ext/viewport.rb'

require_relative 'ext/sprite.rb'
require_relative 'ext/plane.rb'
require_relative 'ext/tilemap.rb'
require_relative 'ext/window.rb'

require_relative 'ext/chuchu.rb'

# Extract RGX into current scope, rather than including,
# this fixes Marshalling from RMVX/RMVXA to rm-srri and back (probably)
RGX.constants.each do |s|
  Object.const_set(s, RGX.const_get(s))
end
