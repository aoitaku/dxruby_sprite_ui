require 'dxruby_sprite_ui'
Window.width = 800
Window.height = 600
if File.exist?('assets/hanazono-mincho.ttf')
  Font.install('assets/hanazono-mincho.ttf')
  Font.default = Font.new(19, '花園明朝A', weight: true)
else
  Font.default = Font.new(18, 'ＭＳ Ｐ明朝', weight: true)
end
if File.exist?('assets/sample-bg.jpg')
  sample_bg = Image.load('assets/sample-bg.jpg')
else
  sample_bg = Image.new(1, 1)
end
ui = SpriteUI::build {
  width :full
  image sample_bg
  ContainerBox {
    image Image.new(768, 568, [192,32,24,16])
    padding 16
    width :full
    TextLabel {
      line_height 38
      padding 18
      width :full
      layout :flow
      aa true
      text_edge true
      text_shadow true
      text_align :space_between
      text <<-EOT
      　諫名和総合高校。通称はイナソー。と、砦門に教えてもらった。イサナワから頭二つを取るとイサソーになるがこれは言いにくいからだということらしい。確かにイサソーはあんまり良さそうな略称ではない。今のはイサソーとヨサソーをかけた高度な、いや、今のなし。
      　イナソーのソーは総合高校の総である。
      　では、総合高校とは何か。総合学科を設けた高校のことである。まあそのまんまだよな。でもWikipediaによると総合高校と称されるものは三種類あるらしい。ややこしい。ともかく、イナソーは総合学科を設けた高校である。
      　単に高校と言った場合、たいてい普通科を指す。そうでない場合は頭に農業だとか工業だとか商業だとかをつける。総合学科っていうのは、その普通科と農業工業商業その他の専門学科の両方を統合したような学科だ。普通科と専門学科両方の分野から受けたい授業を選択できるようになっている。簡単にいうと大学みたいなシステム。大学っても、総合大学のほうな。英語でいうとカレッジじゃなくてユニバーシティ。ユニバーシティって宇宙都市みたいでかっこいいよね。でもユニットバスみたいだよね……。
      「で、七ヶ城は何履修するんだ」
      　隣に座った砦門が声をかけてくる。
      　履修選択説明会を終えて、クラスに戻ってきたところである。これから履修登録機関の間に授業を受けながら実際にどれを受講するのかを決めていくことになるのだが、とりあえず仮にどこを受けてみるか決めておく必要がある。
      「情報系を適当にいくつか、かなあ」
      EOT
    }
  }
}
ui.layout
Window.loop do
  ui.draw
end
