module DXRuby::SpriteUI

  Context = Struct.new(:target, :font)

end

module DXRuby::SpriteUI::TextRenderer

  def self.draw(x, y, drawable, context)
    text, params = *drawable.draw_params
    if params[:aa]
      text.each_line.with_index do |line, i|
        (context.target or Window).draw_font_ex(
          x,
          y + context.font.size * i,
          line.chomp,
          context.font,
          params
        )
      end
    else
      text.each_line.with_index do |line, i|
        (context.target or Window).draw_font(
          x,
          y + context.font.size * i,
          line.chomp,
          context.font,
          params
        )
      end
    end
  end

end
