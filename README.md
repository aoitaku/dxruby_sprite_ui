# DXRuby::SpriteUI

DXRuby::SpriteUI は DXRuby でゲーム向け GUI を実装するための機能を提供するライブラリです。
[Quincite](https://github.com/aoitaku/quincite) のリファレンス実装になっています。


## インストール

Gemfile に

```ruby
gem 'quincite', :git => "https://github.com/aoitaku/quincite.git"
gem 'dxruby_sprite_ui', :git => "https://github.com/aoitaku/dxruby_sprite_ui.git"
```

って書いてコマンドラインから

    $ bundle

を実行する。

あるいは自分で [Quincite のリリースページ](https://github.com/aoitaku/quincite/releases/tag/v0.0.1) と [DXRuby::SpriteUI のリリースページ](https://github.com/aoitaku/dxruby_sprite_ui/releases) から gem をダウンロードして、

    $ gem install quincite-0.0.1.gem
    $ gem install dxruby_sprite_ui-0.0.1.gem

のようにインストールしても OK。

今のところ Rubygems には公開していないので github からダウンロードしてお使いください。

DXRuby 用のライブラリのため、別途 DXRuby をインストールする必要があります。


## 使い方

### サンプルコード

#### ビルダー DSL

```ruby
require 'dxruby'
require 'dxruby_sprite_ui'

ui = SpriteUI::build {
  TextLabel {
    text 'Hello, world.'
  }
}
ui.layout

Window.loop do
  ui.draw
end
```

#### イベントハンドラ

```ruby
require 'dxruby'
require 'dxruby_sprite_ui'

SpriteUI.equip Quincite::MouseEventHandler

ui = SpriteUI::build {
  TextButton {
    text 'Hello, world!'
    hello = true
    add_event_handler :mouse_left_push, -> target {
      target.text = hello ? 'Goodbye, world...' : 'Hello again, world!'
      hello = !hello
      ui.layout
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
```




## コントリビューション

1. フォークします ( https://github.com/aoitaku/dxruby_sprite_ui/fork )
2. feature branch を作ります (`git checkout -b my-new-feature`)
3. 変更をコミットします (`git commit -am 'Add some feature'`)
4. branch に push します (`git push origin my-new-feature`)
5. pull request を投げます
6. 🍣！
