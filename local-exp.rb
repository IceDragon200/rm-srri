#
# rm-srri/local-exp.rb
# vr 1.0.0
#   SRRI Expansion
%w(sr-sprite sr-chipmap bitmap-addons sr-cairobitmap
   texture-cairo-init texture-transition).each do |fn|
  require File.join(File.dirname(__FILE__), 'lib-exp', fn)
end
