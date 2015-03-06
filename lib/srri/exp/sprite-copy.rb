#
# rm-srri/lib/srri/exp/sprite-copy.rb
#   by IceDragon
class SRRI::Sprite
  def copy(other)
    self.x            = other.x
    self.y            = other.y
    self.z            = other.z
    self.ox           = other.ox
    self.oy           = other.oy
    self.zoom_x       = other.zoom_x
    self.zoom_y       = other.zoom_y
    self.angle        = other.angle
    self.bitmap       = other.bitmap
    self.blend_type   = other.blend_type
    self.bush_depth   = other.bush_depth
    self.bush_opacity = other.bush_opacity
    self.opacity      = other.opacity
    self.visible      = other.visible
    self.mirror       = other.mirror
    self.viewport     = other.viewport
    self.wave_amp     = other.wave_amp
    self.wave_length  = other.wave_length
    self.wave_speed   = other.wave_speed
    self.wave_phase   = other.wave_phase
    self.src_rect.set(other.src_rect)
    self.color.set(other.color)
    self.tone.set(other.tone)
    return self
  end
end
