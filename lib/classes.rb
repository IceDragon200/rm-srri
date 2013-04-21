#
# rm-srri/lib/classes.rb
# vr 2.0.0
dir = File.dirname(__FILE__)
%w(RGSSError RGSSReset
   Bitmap Color Font Plane Rect
   Sprite Table Tilemap Tone Viewport Window).each do |fn|
  require File.join(dir, 'class', fn)
end
