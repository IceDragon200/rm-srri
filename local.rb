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
  raise(LoadError, "Could not load StarRuby!")
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

require_relative 'src/interfaces.rb'
require_relative 'src/classes.rb'
require_relative 'src/modules.rb'
require_relative 'src/core.rb'
require_relative 'src/game.rb'
