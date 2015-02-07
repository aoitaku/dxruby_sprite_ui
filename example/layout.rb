require 'dxruby_sprite_ui'
Font.default = Font.new(18, 'ＭＳ ゴシック')

ui = SpriteUI::build {
  layout :flow
  border(width: 1, color: 0xffffff)
  margin 8
  padding 8
  TextLabel {
    border(width: 1, color: 0xffffff)
    margin 4
    padding 4
    text 'フローレイアウト.'
  }
  TextLabel {
    border(width: 1, color: 0xffffff)
    margin 4
    padding 4
    text "このコンテナは"
  }
  TextLabel {
    border(width: 1, color: 0xffffff)
    margin 4
    padding 4
    text '自動配置の際に'
  }
  TextLabel {
    border(width: 1, color: 0xffffff)
    margin 4
    padding 4
    text '画面幅で'
  }
  TextLabel {
    border(width: 1, color: 0xffffff)
    margin 4
    padding 4
    text '折り返しを行います.'
  }
  ContainerBox {
    width 320
    layout :flow
    border(width: 1, color: 0xffffff)
    margin 8
    padding 8
    TextLabel {
      border(width: 1, color: 0xffffff)
      margin 4
      padding 4
      text 'フローレイアウト.'
    }
    TextLabel {
      border(width: 1, color: 0xffffff)
      margin 4
      padding 4
      text "このコンテナは"
    }
    TextLabel {
      border(width: 1, color: 0xffffff)
      margin 4
      padding 4
      text '自動配置の際に'
    }
    TextLabel {
      border(width: 1, color: 0xffffff)
      margin 4
      padding 4
      text 'コンテナ幅'
    }
    TextLabel {
      border(width: 1, color: 0xffffff)
      margin 4
      padding 4
      text ' 320 px で'
    }
    TextLabel {
      border(width: 1, color: 0xffffff)
      margin 4
      padding 4
      text '折り返しを行います.'
    }
  }
  ContainerBox {
    layout :vertical_box
    border(width: 1, color: 0xffffff)
    margin 8
    padding 8
    TextLabel {
      border(width: 1, color: 0xffffff)
      margin 4
      padding 4
      text '垂直ボックスレイアウト.'
    }
    TextLabel {
      border(width: 1, color: 0xffffff)
      margin 4
      padding 4
      text 'このコンテナは'
    }
    TextLabel {
      border(width: 1, color: 0xffffff)
      margin 4
      padding 4
      text '垂直方向に'
    }
    TextLabel {
      border(width: 1, color: 0xffffff)
      margin 4
      padding 4
      text '自動配置されます.'
    }
  }
  ContainerBox {
    layout :horizontal_box
    border(width: 1, color: 0xffffff)
    margin 8
    padding 8
    TextLabel {
      border(width: 1, color: 0xffffff)
      margin 4
      padding 4
      text '水平ボックスレイアウト.'
    }
    TextLabel {
      border(width: 1, color: 0xffffff)
      margin 4
      padding 4
      text 'このコンテナは'
    }
    TextLabel {
      border(width: 1, color: 0xffffff)
      margin 4
      padding 4
      text '水平方向に'
    }
    TextLabel {
      border(width: 1, color: 0xffffff)
      margin 4
      padding 4
      text '自動配置されます.'
    }
  }
}
ui.layout

Window.loop do
  ui.draw
end
