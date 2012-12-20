#
#
#
module Input
class << self

  def init
  end

  DEVICE = :keyboard

  INPUT_TABLE = {
    A: :a,
    B: :s,
    C: :d,
    X: :z,
    Y: :x,
    Z: :c,
    L: :q,
    R: :w,
    LEFT: :left,
    RIGHT: :right,
    UP: :up,
    DOWN: :down,
    SHIFT: :lshiftkey,
    CTRL: :lcontrolkey,
    ALT: :lmenu
  }

private
  def dirs
    keys = StarRuby::Input.keys(DEVICE, duration: 1, delay: 1, interval: 0)
    keys & [:down, :left, :right, :up]
  end

public
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
    else
      return dir4()
    end
  end

  def trigger?(sym)
    return StarRuby::Input.keys(DEVICE, duration: 1).include?(INPUT_TABLE[sym])
  end

  def repeat?(sym)
    return StarRuby::Input.keys(DEVICE,
      duration: 1, delay: 7, interval: 7
    ).include?(INPUT_TABLE[sym])
  end

  def press?(sym)
    return StarRuby::Input.keys(DEVICE,
      duration: 1, delay: 1, interval: 0).include?(INPUT_TABLE[sym])
  end

  def update
    Graphics.starruby.update_state # Input closing etc..etc..
    self
  end

end # class << self
end
