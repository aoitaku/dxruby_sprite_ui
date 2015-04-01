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

  include DXRuby::SpriteUI::Layouter

  # Readables:
  #
  #   - components: 描画するテキストの配列.
  #   - font: 描画に用いるフォント (DXRuby::Font オブジェクト).
  #
  attr_reader :components, :font

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
    self.layout = :vertical_box
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
    text_object = DXRuby::SpriteUI::Text.new
    text_object.text = text.to_s
    @components = [text_object]
  end

  ##############################################################################
  #
  # 描画する.
  #
  # See: SpriteUI::TextRenderer.draw
  #
  def draw
    super
    params = draw_params
    components.each {|component|
      if params[:aa]
        (target or Window).draw_font_ex(component.x, component.y, component.text, font, params)
      else
        (target or Window).draw_font(component.x, component.y, component.text, font, params)
      end
    } if visible?
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
    param
  end

end
