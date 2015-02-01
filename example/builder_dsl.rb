require 'dxruby_sprite_ui'
Font.default = Font.new(22)

ui = SpriteUI::build {
  TextLabel {
    text 'Hello, world.'
    text_edge true
  }
}
ui.layout

Window.loop do
  ui.draw
end
