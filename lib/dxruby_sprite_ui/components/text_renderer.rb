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
      if params[:text_align] == :fill
        curr = line[0]
        char_slice = line.each_char.slice_before {|e|
          curr, prev = e, curr
          /\s/ === e or not (e+prev).ascii_only?
        }
        chars = char_slice.reject {|char| char.reject {|c| /\s/ === c }.empty? }.to_a
        if chars.size == 1
          width = drawable.width - font.get_width(line)
          draw_font[x + width / 2, y, line, font, params]
        else
          width = (drawable.width - drawable.padding * 2) - font.get_width(chars.join)
          pad = width / (chars.size - 1)
          chars.inject(x) do |x, char|
            draw_font[x, y, char.join, font, params]
            x + font.get_width(char.join) + pad
          end
        end
      else
        draw_font[align[line], y, line.chomp, font, params]
      end
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
