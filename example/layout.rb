require 'dxruby_sprite_ui'
Font.default = Font.new(18, 'ＭＳ ゴシック')

ui = SpriteUI::build {
  layout :flow
  padding 8
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
    text '画面幅で'
  }
  TextLabel {
    padding 4
    text '折り返しを行います.'
  }
  ContainerBox {
    width 320
    layout :flow
    padding 8
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
      text 'コンテナ幅 320 px で'
    }
    TextLabel {
      padding 4
      text '折り返しを行います.'
    }
  }
  ContainerBox {
    layout :vertical_box
    padding 8
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
  ContainerBox {
    layout :horizontal_box
    padding 8
    TextLabel {
      padding 4
      text '水平ボックスレイアウト.'
    }
    TextLabel {
      padding 4
      text 'このコンテナは'
    }
    TextLabel {
      padding 4
      text '水平方向に'
    }
    TextLabel {
      padding 4
      text '自動配置されます.'
    }
  }
}
ui.layout

Window.loop do
  ui.draw
end
