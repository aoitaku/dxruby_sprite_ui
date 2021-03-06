################################################################################
#
# VBox
#
# Author:  aoitaku
# Licence: zlib/libpng
#
################################################################################

################################################################################
#
# VBox クラス.
#
class Quincite::UI::VBox < Quincite::UI::ContainerBox

  ##############################################################################
  #
  # インスタンスの初期化.
  #
  # See: SpriteUI::Container#initialize
  #
  def initialize(*args)
    super
    self.style_set :layout, :vertical_box
  end

end
