require 'dxruby'
require 'dxruby_sprite_ui'

SpriteUI.equip :MouseEventHandler

ui = SpriteUI::build {
  TextButton {
    text 'Hello, world!'
    hello = true
    onclick -> target {
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