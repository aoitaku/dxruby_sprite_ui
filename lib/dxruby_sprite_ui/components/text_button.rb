################################################################################
#
# TextButton
#
# Author:  aoitaku
# Licence: zlib/libpng
#
################################################################################



################################################################################
#
# TextButton クラス.
#
# マウスイベントを受け付けることが可能な TextLabel.
#
class Quincite::UI::TextButton < Quincite::UI::TextLabel

  # Property:
  #
  #   color プロパティ.
  #   $TODO: style に分離すべき.
  #
  #   - disable_color : 無効化中の描画色.
  #   - active_color  : アクティブ中の描画色.
  #   - hover_color   : マウスオーバー中の描画色.
  #
  attr_accessor :disable_color, :active_color, :hover_color

  ##############################################################################
  #
  # インスタンスの初期化.
  #
  # See: Quincite::UI::TextLabel#initialize
  #
  def initialize(id='', text='', x=0, y=0, *argv)
    super(id, text, x, y)
    @disable_color = [255,127,127,127]
    @active_color = [255,127,255,223]
    @hover_color = [255,255,223,127]
  end

  ##############################################################################
  #
  # クリック時のイベントハンドラをセットする.
  #
  # Params:
  #   - event_handler = Proc or block
  #
  def onclick=(event_handler=Proc.new)
    add_event_handler(:mouse_left_push, event_handler)
  end

  ##############################################################################
  #
  # イベントハンドラが無効化されているかどうか.
  #
  # Returns: boolean (true|false) ; 無効化されていれば true.
  #
  def disable?
    @disable
  end

  ##############################################################################
  #
  # イベントハンドラを有効化する.
  #
  def enable
    @disable = false
  end

  ##############################################################################
  #
  # イベントハンドラを無効化する.
  #
  def disable
    @disable = true
  end

  ##############################################################################
  #
  # 現在の文字色を取得する.
  #
  # Returns: Array ([FixNum a, r, g, b])
  #
  def color
    if disable?
      @color or @disable_color
    elsif active?
      @active_color
    elsif hover?
      @hover_color
    else
      @color
    end
  end

end
