#!/usr/bin/env ruby
# local.rb
#
# RM - StarRuby Interface
#
$rtp_path = "/home/icy/Dropbox/xdev/RMVXA-RTP/"

# try to load the starruby.so directly
# I used a symlink since my build of starruby is different
# You may want to modify this require
begin
  require_relative './starruby/starruby.so'
rescue(LoadError) => ex
  raise(LoadError, "Could not load StarRuby!\n #{ex.inspect}")
end

require_relative './rgx/local.rb'

# main RGX module, imported from RM-Gosu
module RGX

  # this may be removed later
  DEFAULT_WIDTH  = 544
  DEFAULT_HEIGHT = 416

  #DEFAULT_WIDTH  = 320
  #DEFAULT_HEIGHT = 240

end

require_relative 'lib/interfaces.rb'
require_relative 'lib/classes.rb'
require_relative 'lib/modules.rb'
require_relative 'lib/core.rb'
require_relative 'lib/game.rb'
