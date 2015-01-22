class Quindle::UI::TextButton < Quindle::UI::TextLabel

  def draw_params
    if color
      [text, {color: color}]
    else
      [text, {}]
    end
  end

  def disable?
    @disable
  end

  def enable
    @disable = false
  end

  def disable
    @disable = true
  end

  def color
    if disable?
      @color or [255,127,127,127]
    elsif active?
      [255,127,255,223]
    elsif hover?
      [255,255,223,127]
    else
      @color
    end
  end

end
