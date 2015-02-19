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
        TextLabel {
          padding 4
          text '50% 幅の'
        }
        TextLabel {
          padding 4
          text "ボックスいっぱいに"
        }
        TextLabel {
          padding 4
          text 'テキストラベルの'
        }
        TextLabel {
          padding 4
          text '領域があります'
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
        TextLabel {
          padding 4
          text '右側のボックスも'
        }
        TextLabel {
          padding 4
          text '50% の幅で'
        }
        TextLabel {
          padding 4
          text 'テキストラベルを'
        }
        TextLabel {
          padding 4
          text '垂直に並べています'
        }
      }
    }
  }
}
ui.layout

Window.loop do
  ui.draw
end
