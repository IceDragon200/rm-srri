#
# rm-srri/lib/module/input.rb
# 1.1.6
module SRRI
  module Input
  class << self

    ### class_variables
    @@input_table = {
      ESC:   [:escape],
      A:     [:a],
      B:     [:s, :escape],
      C:     [:d, :enter],
      X:     [:z],
      Y:     [:x],
      Z:     [:c],
      L:     [:q],
      R:     [:w],
      LEFT:  [:left],
      RIGHT: [:right],
      UP:    [:up],
      DOWN:  [:down],
      SHIFT: [:lshiftkey, :rshiftkey],
      CTRL:  [:lcontrolkey, :rcontrolkey],
      ALT:   [:lmenu, :rmenu],
      F1:    [:f1],
      F2:    [:f2],
      F3:    [:f3],
      F4:    [:f4],
      F5:    [:f5],
      F6:    [:f6],
      F7:    [:f7],
      F8:    [:f8],
      F9:    [:f9],
      F10:   [:f10],
      F11:   [:f11],
      F12:   [:f12]
    }

    ### instance_attributes
    attr_accessor :starruby

    ##
    # ::init
    def init
      @keys_cache = {}
      SRRI.try_log do |logger|
        logger.puts("SRRI | Input initialized")
      end
    end

    ##
    # ::input_table
    def input_table
      @@input_table
    end

    ##
    # ::input_table=(Hash new_table)
    def input_table=(new_table)
      @@input_table = Hash[new_table.map do |(k, v)|
        [k.to_sym, Array(v).map(&:to_sym)]
      end]
    end

  private

    ##
    #
    def correct_key(sym)
      return @@input_table[sym] || Array(sym)
    end

    def keys(device, dur=0, del=-1, int=-1)
      key = [device,dur,del,int]
      @keys_cache[key] ||= StarRuby::Input.keys(device,
                                                duration: dur, delay: del, interval: int)
    end

    def dirs
      keys(:keyboard, 1, 1, 0) & [:down, :left, :right, :up]
    end

    def has_key?(keys, *want)
      return want.any? { |k| keys.include?(k) }
    end

  public

    def any_input?
      return true if !(keys(:keyboard, 1, 1, 0).empty?)
      return !(keys(:mouse, 1, 1, 0).empty?)
    end

    def dir4
      keys = dirs()

      if    keys.include?(:down)  then 2
      elsif keys.include?(:left)  then 4
      elsif keys.include?(:right) then 6
      elsif keys.include?(:up)    then 8
      else                      return 0
      end
    end

    def dir8
      keys = dirs()

      if    keys.include?(:down) and
            keys.include?(:left)     then 1
      elsif keys.include?(:down) and
            keys.include?(:right)    then 3
      elsif keys.include?(:up)   and
            keys.include?(:left)     then 7
      elsif keys.include?(:up)   and
            keys.include?(:right)    then 9
      elsif keys.include?(:down)     then 2
      elsif keys.include?(:left)     then 4
      elsif keys.include?(:right)    then 6
      elsif keys.include?(:up)       then 8
      else                         return 0
      end
    end

    def sr_repeat_rate
      10
    end

    def sr_trigger?(device, *syms)
      has_key?(keys(device, 1), *syms)
    end

    def sr_repeat?(device, *syms)
      #has_key?(keys(device, 1, 7, 7), *syms)
      has_key?(keys(device, 1, sr_repeat_rate, sr_repeat_rate), *syms)
    end

    def sr_press?(device, *syms)
      has_key?(keys(device, 1, 1, 0), *syms)
    end

    # Wrapper for SRRI (RGSS2/3)
    def trigger?(*syms)
      syms.any? do |sym|
        sr_trigger?(:keyboard, *correct_key(sym))
      end
    end

    def repeat?(*syms)
      syms.any? do |sym|
        sr_repeat?(:keyboard, *correct_key(sym))
      end
    end

    def press?(*syms)
      syms.any? do |sym|
        sr_press?(:keyboard, *correct_key(sym))
      end
    end

    def update
      @keys_cache.clear
      return false unless @starruby
      return false if @starruby.disposed?
      return SRRI.kill_starruby if @starruby.window_closing?
      @starruby.update_state
      raise SRRI::RGSSReset if Input.trigger?(:f12)
    end

  end # class << self
  end
end