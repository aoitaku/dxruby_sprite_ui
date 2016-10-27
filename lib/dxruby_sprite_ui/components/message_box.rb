################################################################################
#
# MessageBox
#
# Author:  aoitaku
# Licence: zlib/libpng
#
################################################################################

################################################################################
#
# MessageBox クラス.
#
# 複数行文字列を描画するためのコンポーネント.
#
class Quincite::UI::MessageBox < Quincite::UI::TextLabel

  def initialize(id='', text='', x=0, y=0, *argv)
    super(id, x, y)
    self.style_set :layout, :flow
    self.text = text
    @line_height = 1.0
    self.style_set :align_items, :top
    self.style_set :justify_content, :left
    @font = Font.default
  end

  def text=(text)
    @components = []
    @text = text ? text.to_s : text
  end

  def append_text(text)
    @text = text ? text.to_s : text
  end

  def flow_segment
    unless @text
      @components = []
      return
    end
    if @text == "\n"
      @components.last.style_set(:break_after, true)
      return
    end
    max_width = @width
    text_margin = [line_spacing, 0]
    @components += @text.split(/([^\n]\n)/).flat_map {|line|
      line.split.flat_map {|chars|
        line_break.breakables(chars).map {|word|
          DXRuby::SpriteUI::Text.new.tap do |text_object|
            text_object.text = word
            text_object.style_set(:margin, text_margin)
          end
        }.to_a
      }.tap {|chars| chars.last.style_set(:break_after, true) if /\n\Z/ === line }
    }
    @text = ''
  end

end

