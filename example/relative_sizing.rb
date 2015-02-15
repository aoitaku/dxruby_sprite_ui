require 'dxruby_sprite_ui'
Font.default = Font.new(18, 'ＭＳ ゴシック')

ui = SpriteUI::build {
  layout :flow
  TextLabel {
    border width: 1, color: 0xffffff
    padding 8
    margin 4
    width :full
    text '相対的なサイズ指定'
  }
  ContainerBox {
    layout :flow
    width :full
    margin 4
    ContainerBox {
      width 0.5
      layout :vertical_box
      border width: 1, color: 0xffffff
      padding 4
      TextLabel {
        padding 4
        text 'フローレイアウト.'
      }
      TextLabel {
        padding 4
        text "このコンテナは"
      }
      TextLabel {
        padding 4
        text '自動配置の際に'
      }
      TextLabel {
        padding 4
        text 'コンテナ幅'
      }
    }
    ContainerBox {
      width 0.5
      layout :vertical_box
      border width: 1, color: 0xffffff
      padding 4
      TextLabel {
        padding 4
        text '垂直ボックスレイアウト.'
      }
      TextLabel {
        padding 4
        text 'このコンテナは'
      }
      TextLabel {
        padding 4
        text '垂直方向に'
      }
      TextLabel {
        padding 4
        text '自動配置されます.'
      }
    }
  }
}
ui.layout

Window.loop do
  ui.draw
end
