################################################################################
#
# TextRenderer
#
# Author:  aoitaku
# Licence: zlib/libpng
#
################################################################################



################################################################################
#
# Context クラス.
#
# 文字列の描画に用いる DXRuby::RenderTarget と DXRuby::Font を保持する構造体.
#
# Accessors:
#   - target : DXRuby::RenderTarget 描画先の RenderTarget オブジェクト.
#   - font   : DXRuby::Font 描画に用いる Font オブジェクト.
#
module DXRuby::SpriteUI

  Context = Struct.new(:target, :font)

end

################################################################################
#
# TextRenderer クラス.
#
# 文字列描画コンテキストと描画対象、座標を元に文字列の描画を行う.
#
module DXRuby::SpriteUI::TextRenderer

  ##############################################################################
  #
  # 描画を行う.
  #
  # Params:
  #   - x        : x 座標.
  #   - y        : y 座標.
  #   - drawable : draw_params メソッドを実装したオブジェクト.
  #   - context  : SpriteUI::Context オブジェクト.
  #
  # Todo:
  #   drawable.width を drawable 経由でない方法で参照する方法を検討する.
  #
  def self.draw(x, y, drawable, context)
    text, params = *drawable.draw_params
    target, font = context.target, context.font
    align = text_align(params[:text_align], x, drawable.width, font)
    draw_font = (target or Window).method(params[:aa] ? :draw_font_ex : :draw_font)
    text.each_line.inject(y) do |y, line|
      if params[:text_align] == :fill
        align_fill(draw_font, line, drawable)
      else
        draw_font[align[line], y, line.chomp, font, params]
      end
      y + font.size
    end
  end

  def self.align_fill(draw_font, text, drawable)
    curr = text[0]
    chars = text.each_char.slice_before {|e|
      curr, prev = e, curr
      /\s/ === e or not (e + prev).ascii_only?
    }.reject {|char| char.reject {|c| /\s/ === c }.empty? }.to_a
    if chars.size == 1
      width = drawable.width - font.get_width(text)
      draw_font[x + width / 2, y, text, font, params]
    else
      width = (drawable.width - drawable.padding * 2) - font.get_width(chars.join)
      pad = width / (chars.size - 1)
      chars.inject(x) do |x, char|
        draw_font[x, y, char.join, font, params]
        x + font.get_width(char.join) + pad
      end
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
