module DXRuby::SpriteUI

  Context = Struct.new(:target, :font)

end

module DXRuby::SpriteUI::TextRenderer

  def self.draw(x, y, drawable, context)
    text, params = *drawable.draw_params
    target, font = context.target, context.font
    align = text_align(params[:text_align], x, drawable.width, font)
    draw_font = (target or Window).method(params[:aa] ? :draw_font_ex : :draw_font)
    text.each_line.inject(y) do |y, line|
      draw_font[align[line], y, line.chomp, font, params]
      y + font.size
    end
  end

  def self.text_align(align, x, width, font)
    case align
    when :center
      -> text { x + (width - font.get_width(text)) / 2 }
    when :right
      -> text { x + (width - font.get_width(text)) }
    else
      -> * { x }
    end
  end

end
