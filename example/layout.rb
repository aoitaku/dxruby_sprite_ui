require 'dxruby_sprite_ui'
Font.default = Font.new(22)

ui = SpriteUI::build {
  layout :flow
  TextLabel {
    text 'フローレイアウト.'
  }
  TextLabel {
    text "このコンテナは"
  }
  TextLabel {
    text '自動配置の際に'
  }
  TextLabel {
    text '画面幅で'
  }
  TextLabel {
    text '折り返しを行います.'
  }
  ContainerBox {
    width 320
    layout :flow
    TextLabel {
      text 'フローレイアウト.'
    }
    TextLabel {
      text "このコンテナは"
    }
    TextLabel {
      text '自動配置の際に'
    }
    TextLabel {
      text 'コンテナ幅 320 px で'
    }
    TextLabel {
      text '折り返しを行います.'
    }
  }
  ContainerBox {
    layout :vertical_box
    TextLabel {
      text '垂直ボックスレイアウト.'
    }
    TextLabel {
      text 'このコンテナは'
    }
    TextLabel {
      text '垂直方向に'
    }
    TextLabel {
      text '自動配置されます.'
    }
  }
  ContainerBox {
    layout :horizontal_box
    TextLabel {
      text '水平ボックスレイアウト.'
    }
    TextLabel {
      text 'このコンテナは'
    }
    TextLabel {
      text '水平方向に'
    }
    TextLabel {
      text '自動配置されます.'
    }
  }
}
ui.layout

Window.loop do
  ui.draw
end
