module DXRuby::SpriteUI

  Context = Struct.new(:target, :font)

end

module DXRuby::SpriteUI::TextRenderer

  def self.draw(x, y, drawable, context)
    text, params = *drawable.draw_params
    if params[:aa]
      (context.target or Window).draw_font_ex(x, y, text, context.font, params)
    else
      (context.target or Window).draw_font(x, y, text, context.font, params)
    end
  end

end
