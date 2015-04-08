################################################################################
#
# TextLabel
#
# Author:  aoitaku
# Licence: zlib/libpng
#
################################################################################

require 'unicode/line_break'

################################################################################
#
# TextLabel クラス.
#
# 文字列を描画するためのシンプルなコンポーネント.
#
class Quincite::UI::TextLabel < DXRuby::SpriteUI::Base

  def self.unicode
    unless @unicode
      db = Unicode::DB.new
      @unicode = {
        line_break: Unicode::LineBreak.new(db),
        east_asian_width: Unicode::EastAsianWidth.new(db)
      }
    end
    @unicode
  end

  def line_break
    Quincite::UI::TextLabel.unicode[:line_break]
  end

  def east_asian_width
    Quincite::UI::TextLabel.unicode[:east_asian_width]
  end

  include DXRuby::SpriteUI::Layouter

  # Readables:
  #
  #   - components: 描画するテキストの配列.
  #   - font: 描画に用いるフォント (DXRuby::Font オブジェクト).
  #   - text_align: 描画するテキストの水平位置揃え.
  #
  attr_reader :components, :font, :text_align

  # Accessors:
  #
  #   - aa          : アンチエイリアスの有無.
  #   - color       : 描画の文字色.
  #   - text_edge   : 袋文字のパラメータ.
  #   - text_shadow : 文字影のパラメータ.
  #
  attr_accessor :aa, :color, :text_edge, :text_shadow

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
    @align_items = :top
    @justify_content = :left
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

  # 行に分割するのは flow_resize 側に任せる.
  # flow_segment では禁則処理を行って分割可能位置で分割を行う.
  def flow_segment
    max_width = @width
    @components = @text.split.map {|chars|
      line_break.breakables(chars).map {|word|
        DXRuby::SpriteUI::Text.new.tap do |text_object|
          text_object.text = word
        end
      }.to_a
    }.flatten
  end
  private :flow_segment

  # 現実装だと垂直レイアウトでは均等割はできない.
  # 均等割するときは入れ子にしないといけない.
  # 現在の Text クラスのような文字～語句単位のオブジェクトとは別に,
  # 複数の文字～語句をひとまとまりにした行単位のオブジェクトが必要かも.
  def vertical_box_segment
    @components = @text.each_line.map do |line|
      DXRuby::SpriteUI::Text.new.tap do |text_object|
        text_object.text = line
      end
    end
  end
  private :vertical_box_segment

  def narrow?(char)
    return false unless char
    case east_asian_width.east_asian_width(char.ord)
    when Unicode::EastAsianWidth::N, Unicode::EastAsianWidth::Na
      true
    else
      false
    end
  end
  private :narrow?

  def horizontal_box_segment
    @components = @text.each_char.slice_before {|char|
      curr, prev = char, curr
      /\s/ === char or (not narrow?(char) and not narrow?(prev))
    }.lazy.map(&:join).reject {|word| /\s/ === word }.map {|word|
      DXRuby::SpriteUI::Text.new.tap do |text_object|
        text_object.text = word
      end
    }.to_a
  end
  private :horizontal_box_segment

  def flow_resize
    flow_segment
    super
  end

  def vertical_box_resize
    vertical_box_segment
    super
  end

  def horizontal_box_resize
    horizontal_box_segment
    super
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

  def text_align=(align)
    @justify_content = align
  end

  ##############################################################################
  #
  # 描画する.
  #
  # See: SpriteUI::TextRenderer.draw
  #
  def draw
    return unless visible?
    super
    # 事前にパラメータを用意しておく
    param = draw_params
    # 描画方式の選択
    draw = (target or Window).method(aa? && :draw_font_ex || :draw_font)
    components.each do |component|
      draw.(component.x, component.y, component.text, font, param)
    end
  end

  def aa?
    aa || text_edge || text_shadow
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
    if color
      param[:color] = color
    end
    param
  end

end
