module DXRuby::SpriteUI

  Context = Struct.new(:target, :font)

end

module DXRuby::SpriteUI::TextRenderer

  def self.draw(x, y, drawable, context)
    text, params = *drawable.draw_params
    alignment = if params[:text_align]
      case params[:text_align]
      when :center
        -> text { x + (drawable.width - context.font.get_width(text)) / 2 }
      when :right
        -> text { x + (drawable.width - context.font.get_width(text)) }
      else
        -> text { x }
      end
    else
      -> text { x }
    end
    if params[:aa]
      text.each_line.with_index do |line, i|
        (context.target or Window).draw_font_ex(
          alignment[text],
          y + context.font.size * i,
          line.chomp,
          context.font,
          params
        )
      end
    else
      text.each_line.with_index do |line, i|
        (context.target or Window).draw_font(
          alignment[text],
          y + context.font.size * i,
          line.chomp,
          context.font,
          params
        )
      end
    end
  end

end
