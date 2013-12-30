#
# rm-srri/lib/srri/module/graphics/alpha_transition.rb
#
module SRRI
  module Graphics

    class AlphaTransition

      def self.transition(target, t1, t2, delta)
        StarRuby::Transition.crossfade(target, t1, t2, delta)
      end

      def self.dispose
        return
      end

    end

  end
end