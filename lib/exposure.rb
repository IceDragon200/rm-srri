#
# rm-srri/lib/exposure.rb
# vr 1.1.0
%w(Bitmap Color Font Plane Rect RGSSError RGSSReset
   Sprite Table Tilemap Tone Viewport Window
   Audio Graphics Input).each do |const_name|
  if !Object.const_defined?(const_name)
    Object.const_set(const_name, SRRI.const_get(const_name))
  else
    raise(SRRI::ExposureError,
          "%s was already defined, did you include rm-srri first?" % const_name)
  end
end
