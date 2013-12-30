#
# rm-srri/lib/classes.rb
# vr 2.0.0
dir = File.dirname(__FILE__)
%w(rgss_error rgss_reset
   bitmap color font plane rect
   sprite table tilemap tone viewport window).each do |fn|
  require File.join(dir, 'class', fn)
end
