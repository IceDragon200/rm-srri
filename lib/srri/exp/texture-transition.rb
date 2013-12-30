#
# rm-srri/lib-exp/texture-transition.rb
# vr 1.0.0
class StarRuby::Texture

  ##
  #
  def to_transition
    return StarRuby::Transition.from_texture(self)
  end unless method_defined?(:to_transition)

end