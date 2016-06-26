################################################################################
#
# ContainerBox
#
# Author:  aoitaku
# Licence: zlib/libpng
#
################################################################################

################################################################################
#
# ContainerBox クラス.
#
class Quincite::UI::ContainerBox < DXRuby::SpriteUI::Container

  include Quincite::UI::Layouter

  ##############################################################################
  #
  # インスタンスの初期化.
  #
  # See: SpriteUI::Container#initialize
  #
  def initialize(*args)
    super
    self.style_set :justify_content, :left
    self.style_set :align_items, :top
    self.style_set :layout, :vertical_box
  end

end
