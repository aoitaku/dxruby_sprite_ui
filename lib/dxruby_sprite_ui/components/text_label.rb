################################################################################
#
# TextLabel
#
# Author:  aoitaku
# Licence: zlib/libpng
#
################################################################################



################################################################################
#
# TextLabel クラス.
#
# 文字列を描画するためのシンプルなコンポーネント.
#
class Quincite::UI::TextLabel < DXRuby::SpriteUI::Base

  # Readables:
  #
  #   - text: 描画するテキスト.
  #   - font: 描画に用いるフォント (DXRuby::Font オブジェクト).
  #
  attr_reader :text, :font

  # Accessors:
  #
  #   - aa          : アンチエイリアスの有無.
  #   - color       : 描画の文字色.
  #   - text_edge   : 袋文字のパラメータ.
  #   - text_shadow : 文字影のパラメータ.
  #
  attr_accessor :aa, :color, :text_edge, :text_shadow, :text_align

  ##############################################################################
  #
  # インスタンスの初期化.
  #
  # See: SpriteUI::Base#initialize
  #
  def initialize(id='', text='', x=0, y=0, *argv)
    super(id, x, y)
    self.text = text
    @font = Font.default
  end

  ##############################################################################
  #
  # フォントを設定する.
  #
  # Params:
  #   - font : 文字列描画に使う DXRuby::Font オブジェクト.
  #
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

  ##############################################################################
  #
  # 文字列を設定する.
  #
  # Params:
  #   - text : テキストラベルに表示する文字列.
  #
  def text=(text)
    @text = text.to_s
  end

  ##############################################################################
  #
  # 描画する.
  #
  # See: SpriteUI::TextRenderer.draw
  #
  def draw
    super
    TextRenderer.draw(x + padding_left, y + padding_top, self, context) if visible?
  end

  ##############################################################################
  #
  # 領域の幅を取得する.
  #
  # テキストの描画幅にパディングを含めた幅を返す.
  #
  def content_width
    if text.empty?
      super
    else
      text.each_line.map {|line|
        font.get_width(line)
      }.max + padding_left + padding_right
    end
  end

  ##############################################################################
  #
  # 領域の高さを取得する.
  #
  # テキストの描画高さにパディングを含めた高さを返す.
  #
  def content_height
    if text.empty?
      super
    else
      font.size * (text.each_line.to_a.size) + padding_top + padding_bottom
    end
  end

  ##############################################################################
  #
  # 描画コンテキストを取得する.
  #
  # Returns: SpriteUI::Context
  #
  def context
    Context[target, font]
  end

  ##############################################################################
  #
  # 文字描画パラメータを取得する.
  #
  # Returns: Array ([String text, Hash params])
  #
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
    if text_align
      param[:text_align] = text_align
    end
    if color
      param[:color] = color
    end
    param[:aa] = aa || text_edge || text_shadow
    [text, param]
  end

  ##############################################################################
  #
  # コンポーネントの領域の更新.
  #
  def resize(parent)
    super
    update_collision
  end

end
