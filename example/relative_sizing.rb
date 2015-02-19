require 'dxruby_sprite_ui'
Font.default = Font.new(18, 'ＭＳ ゴシック')

SpriteUI.equip :MouseEventHandler
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
    margin 2
    top -2
    width :full
    ContainerBox {
      width 0.5
      ContainerBox {
        border width: 1, color: 0xffffff
        layout :vertical_box
        width :full
        padding 4
        margin 2
        TextButton {
          padding 4
          text '50% 幅の'
          width :full
        }
        TextButton {
          padding 4
          text "ボックスいっぱいに"
          width :full
        }
        TextButton {
          padding 4
          text 'テキストボタンの'
          width :full
        }
        TextButton {
          padding 4
          text '領域があります'
          width :full
        }
      }
    }
    ContainerBox {
      width 0.5
      ContainerBox {
        layout :vertical_box
        border width: 1, color: 0xffffff
        width :full
        padding 4
        margin 2
        TextButton {
          padding 4
          text '右側のボックスも'
          width :full
        }
        TextButton {
          padding 4
          text '50% の幅で'
          width :full
        }
        TextButton {
          padding 4
          text 'テキストボタンを'
          width :full
        }
        TextButton {
          padding 4
          text '垂直に並べています'
          width :full
        }
      }
    }
  }
}
ui.layout
mouse_event_dispatcher = SpriteUI::MouseEventDispatcher.new(ui)
Window.loop do
  mouse_event_dispatcher.update
  mouse_event_dispatcher.dispatch
  ui.draw
end
