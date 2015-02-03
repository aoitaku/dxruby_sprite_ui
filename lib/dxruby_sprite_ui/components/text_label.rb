class Quincite::UI::TextLabel < DXRuby::SpriteUI::Base

  attr_reader :text, :font
  attr_accessor :aa, :color, :text_edge, :text_shadow

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
    TextRenderer.draw(x + padding, y + padding, self, context) if visible?
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
    Context[target, font]
  end

  def draw_params
    param = {}
    if text_edge
      param[:edge] = true
      if Hash === text_edge
        param[:edge_color] = text_edge[:color] if text_edge[:color]
        param[:edge_width] = text_edge[:width] if text_edge[:width]
        param[:edge_level] = text_edge[:level] if text_edge[:level]
      end
    end
    if text_shadow
      param[:shadow] = true
      if Hash === text_shadow
        param[:shadow_edge] = text_shadow[:edge] if text_shadow[:edge]
        param[:shadow_color] = text_shadow[:color] if text_shadow[:color]
        param[:shadow_x] = text_shadow[:x] if text_shadow[:x]
        param[:shadow_y] = text_shadow[:y] if text_shadow[:y]
      end
    end
    if color
      param[:color] = color
    end
    param[:aa] = aa || text_edge || text_shadow
    [text, param]
  end

end
