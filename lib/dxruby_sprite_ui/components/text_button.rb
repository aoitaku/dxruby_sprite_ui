class Quincite::UI::TextButton < Quincite::UI::TextLabel

  attr_accessor :disable_color, :active_color, :hover_color

  def initialize(id='', text='', x=0, y=0, *argv)
    super(id, text, x, y)
    @disable_color = [255,127,127,127]
    @active_color = [255,127,255,223]
    @hover_color = [255,255,223,127]
  end

  def onclick=(event_handler=Proc.new)
    add_event_handler(:mouse_left_push, event_handler)
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
      @color or @disable_color
    elsif active?
      @active_color
    elsif hover?
      @hover_color
    else
      @color
    end
  end

end
