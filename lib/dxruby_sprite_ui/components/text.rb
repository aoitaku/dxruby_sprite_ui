################################################################################
#
# Text
#
# Author:  aoitaku
# Licence: zlib/libpng
#
################################################################################

################################################################################
#
# Text クラス.
#
# 文字列を描画するためのシンプルなコンポーネント.
#
class DXRuby::SpriteUI::Text < DXRuby::SpriteUI::Base

  # Readables:
  #
  #   - text: 描画するテキスト.
  #
  attr_reader :text

  ##############################################################################
  #
  # インスタンスの初期化.
  #
  # See: SpriteUI::Base#initialize
  #
  def initialize(id='', text='', x=0, y=0, *argv)
    super(id, x, y)
    self.text = text
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
  # コンポーネントの領域の更新.
  #
  # layout プロパティに応じたリサイズを行う.
  #
  # Params:
  #   - width  = 親要素の幅.
  #   - height = 親要素の高さ.
  #   - parent = 親要素.
  #
  def resize(parent)
    super
    @content_width = parent.font.get_width(text)
    @content_height = parent.font.size
    update_collision
    self
  end

end
