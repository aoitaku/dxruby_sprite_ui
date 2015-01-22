class Quindle::UI::TextLabel < Quindle::SpriteUI::Base

  attr_reader :text, :font
  attr_accessor :color

  def initialize(id='', text='', x=0, y=0, *argv)
    super(id, x, y)
    self.text = text
    @font = Font.default
  end

  def font=(font)
    case font
    when Font
      @font = font
    when String
      @font = Font.new(Font.default.size, font)
    else
      @font = Font.new(Font.default.size, font.to_s)
    end
  end

  def text=(text)
    @text = text.to_s
  end

  def draw
    super
    TextRenderer.draw(x, y, self, context) if visible?
  end

  def content_width
    if text.empty?
      super
    else
      font.get_width(text)
    end
  end

  def content_height
    if text.empty?
      super
    else
      font.size
    end
  end

  def context
    Quindle::Context[target, font]
  end

  def draw_params
    if color
      [text, {color: color}]
    else
      [text, {}]
    end
  end

end
