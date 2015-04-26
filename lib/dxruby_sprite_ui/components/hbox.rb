################################################################################
#
# HBox
#
# Author:  aoitaku
# Licence: zlib/libpng
#
################################################################################

################################################################################
#
# HBox クラス.
#
class Quincite::UI::HBox < Quincite::UI::ContainerBox

  ##############################################################################
  #
  # インスタンスの初期化.
  #
  # See: SpriteUI::Container#initialize
  #
  def initialize(*args)
    super
    self.layout = :horizontal_box
  end

end
