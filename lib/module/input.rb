#
# src/module/input.rb
# 1.16
module Input
class << self

  def init
  end

  INPUT_TABLE = {
    A: :a,
    B: [:s, :escape],
    C: [:d, :enter],
    X: :z,
    Y: :x,
    Z: :c,
    L: :q,
    R: :w,
    LEFT:  :left,
    RIGHT: :right,
    UP:    :up,
    DOWN:  :down,
    SHIFT: :lshiftkey,
    CTRL:  :lcontrolkey,
    ALT:   :lmenu,

    F5: :f5,
    F6: :f6,
    F7: :f7,
    F8: :f8,
    F9: :f9,
    F10: :f10,
    F11: :f11
  }

  INPUT_TABLE.each_pair do |key, value|
    const_set(key, value)
  end

private
  def correct_key(sym)
    return Array(INPUT_TABLE[sym] || sym)
  end

  def keys(device, dur=0, del=-1, int=-1)
    return StarRuby::Input.keys(
      device, duration: dur, delay: del, interval: int)
  end

  def dirs
    keys(:keyboard, 1, 1, 0) & [:down, :left, :right, :up]
  end

  def has_key?(keys, *want)
    return want.any? do |k| keys.include?(k) end
  end

public

  def any_input?
    return true if !(keys(:keyboard, 1, 1, 0).empty?)
    return !(keys(:mouse, 1, 1, 0).empty?)
  end

  def dir4
    keys = dirs()

    if keys.include?(:down)
      return 2
    elsif keys.include?(:left)
      return 4
    elsif keys.include?(:right)
      return 6
    elsif keys.include?(:up)
      return 8
    else
      return 0
    end
  end

  def dir8
    keys = dirs()

    if keys.include?(:down) and keys.include?(:left)
      return 1
    elsif keys.include?(:down) and keys.include?(:right)
      return 3
    elsif keys.include?(:up) and keys.include?(:left)
      return 7
    elsif keys.include?(:up) and keys.include?(:right)
      return 9
    elsif keys.include?(:down)
      return 2
    elsif keys.include?(:left)
      return 4
    elsif keys.include?(:right)
      return 6
    elsif keys.include?(:up)
      return 8
    else
      return 0
    end
  end

  def sr_trigger?(device, *syms)
    has_key?(keys(device, 1), *syms)
  end

  def sr_repeat?(device, *syms)
    #has_key?(keys(device, 1, 7, 7), *syms)
    has_key?(keys(device, 1, 10, 10), *syms)
  end

  def sr_press?(device, *syms)
    has_key?(keys(device, 1, 1, 0), *syms)
  end

  # Wrapper for SRRI (RGSS2/3)
  def trigger?(sym)
    sr_trigger?(:keyboard, *correct_key(sym))
  end

  def repeat?(sym)
    sr_repeat?(:keyboard, *correct_key(sym))
  end

  def press?(sym)
    sr_press?(:keyboard, *correct_key(sym))
  end

  def update
    Graphics.starruby.update_state # Input closing etc..etc..
    return self
  end

end # class << self
end