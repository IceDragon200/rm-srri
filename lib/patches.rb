#
# rm-srri/lib/patches.rb
# vr 2.0.0
dir = File.dirname(__FILE__)
%w(tone).each do |fn|
  require File.join(dir, 'patches', fn)
end
