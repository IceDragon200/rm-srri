#
# local.rb
#

# Main Extension Shared Library
require_relative 'rgx.so'

require_relative 'table.rb'
require_relative 'rect.rb'

require_relative 'color.rb'
require_relative 'tone.rb'

require_relative 'font.rb'

require_relative 'bitmap.rb'

require_relative 'viewport.rb'

require_relative 'sprite.rb'
require_relative 'plane.rb'
require_relative 'tilemap.rb'
require_relative 'window.rb'

require_relative 'chuchu.rb'

# Extract RGX into current scope, rather than including,
# this fixes Marshalling from RMVX/RMVXA to rm-srri and back (probably)
RGX.constants.each do |s|
  Object.const_set(s, RGX.const_get(s))
end
