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

  # layout プロパティ.
  attr_writer :layout

  ##############################################################################
  #
  # インスタンスの初期化.
  #
  # See: SpriteUI::Container#initialize
  #
  def initialize(*args)
    super
    self.layout = :vertical_box
  end

  ##############################################################################
  #
  # コンポーネントの領域の更新.
  #
  # layout プロパティに応じたリサイズを行う.
  #
  # Params:
  #   - width  = 親要素の幅.
  #   - height = 親要素の高さ.
  #   - margin = 親要素からの余白.
  #
  def resize(width, height, margin)
    super
    __send__(:"#{@layout}_resize")
    update_collision
    self
  end

  ##############################################################################
  #
  # コンポーネントの座標の更新.
  #
  # layout プロパティに応じた移動を行う.
  #
  # Params:
  #   - ox = 親要素の x 座標.
  #   - oy = 親要素の y 座標.
  #
  def move(ox=0, oy=0)
    super
    __send__(:"#{@layout}_move")
    self
  end

  ##############################################################################
  #
  # フローレイアウト時のコンポーネントの領域を更新する.
  #
  # 子コンポーネントの resize を行う.
  #
  def flow_resize
    v_margin = padding
    @computed_width = (@width or (image and image.width) or Window.width)
    @computed_height = components.lazy.each {|component|
      component.resize(@computed_width, nil, padding)
    }.slice_before(&components_overflow?).inject(0) {|height, row|
      component = row.max_by(&:layout_height)
      next height if component.position == :absolute
      v_space = [v_margin, component.margin].max + height
      v_margin = component.margin
      v_space + component.height
    } + [v_margin, padding].max
  end
  private :flow_resize

  ##############################################################################
  #
  # フローレイアウト時のコンポーネントの座標を更新する.
  #
  # 子コンポーネントの move を行う.
  #
  def flow_move
    v_margin = padding
    components.slice_before(&components_overflow?).inject(0) do |height, row|
      component = row.max_by(&:layout_height)
      max_component_height = component.height
      v_space = [v_margin, component.margin].max + height
      v_margin = component.margin
      h_margin = padding
      row.inject(0) do |width, component|
        h_space = [h_margin, component.margin].max + width
        x = self.x + h_space
        y = self.y + v_space + (max_component_height - component.height) / 2
        component.move(x, y)
        next width if component.position == :absolute
        h_margin = component.margin
        h_space + component.width
      end
      v_space + max_component_height
    end
  end
  private :flow_move

  ##############################################################################
  #
  # コンテナ幅に収まる位置でコンポーネントを列に分割するための判定用ブロック.
  #
  # Returns: Proc (lambda)
  #
  def components_overflow?
    h_margin = padding
    width = 0
    max_width = @computed_width
    -> component {
      next false if component.position == :absolute
      h_space = [h_margin, component.margin].max + component.width
      expected_width = width + component.layout_width + padding * 2
      if width > 0 and expected_width > max_width
        width = h_space
        h_margin = padding
        true
      else
        width += h_space
        h_margin = component.margin
        false
      end
    }
  end
  private :components_overflow?

  ##############################################################################
  #
  # 垂直ボックスレイアウト時のコンポーネントの領域を更新する.
  #
  def vertical_box_resize
    v_margin = padding
    component = components.max_by(&:layout_width)
    @computed_width = component.width + [component.margin, padding].max * 2
    @computed_height = components.inject(0) {|height, component|
      component.resize(@computed_width, nil, padding)
      next height if component.position == :absolute
      v_space = [v_margin, component.margin].max + height
      v_margin = component.margin 
      v_space + component.height
    } + [v_margin, padding].max
  end
  private :vertical_box_resize

  ##############################################################################
  #
  # 垂直ボックスレイアウト時のコンポーネントの座標を更新する.
  #
  def vertical_box_move
    v_margin = padding
    components.inject(0) do |height, component|
      v_space = [v_margin, component.margin].max + height
      x = self.x + [padding, component.margin].max
      y = self.y + v_space
      component.move(x, y)
      next height if component.position == :absolute
      v_margin = component.margin 
      v_space + component.height
    end
  end
  private :vertical_box_move

  ##############################################################################
  #
  # 水平ボックスレイアウト時のコンポーネントの領域を更新する.
  #
  def horizontal_box_resize
    h_margin = padding
    component = components.max_by(&:layout_width)
    @computed_height = component.height + [component.margin, padding].max * 2
    @computed_width = components.inject(0) {|width, component|
      component.resize(nil, @computed_height, padding)
      next width if component.position == :absolute
      h_space = [h_margin, component.margin].max + width
      h_margin = component.margin
      h_space + component.width
    } + [h_margin, padding].max
  end
  private :horizontal_box_resize

  ##############################################################################
  #
  # 水平ボックスレイアウト時のコンポーネントの座標を更新する.
  #
  def horizontal_box_move
    h_margin = padding
    components.inject(0) do |width, component|
      h_space = [h_margin, component.margin].max + width
      x = self.x + h_space
      y = self.y + (self.height - component.height) / 2
      component.move(x, y)
      next width if component.position == :absolute
      h_margin = component.margin
      h_space + component.width
    end
  end
  private :horizontal_box_move

end
