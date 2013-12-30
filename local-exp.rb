#
# rm-srri/local-exp.rb
# vr 1.0.0
#   SRRI Expansion
%w(
  srri/exp/bitmap-addons
  srri/exp/cairo_bitmap
  srri/exp/chipmap
  srri/exp/soft_sprite
  srri/exp/vector
  srri/exp/texture-cairo-init
  srri/exp/texture-extension
  srri/exp/texture-transition
  ).each do |fn|
  require File.join(File.dirname(__FILE__), 'lib', fn)
end