################################################################################
# 
# 
# 
# 
################################################################################

################################################################################
#
# 
#
class Quincite::UI::ContainerBox < DXRuby::SpriteUI::Container

  attr_writer :layout

  ##############################################################################
  #
  # 
  #
  def initialize(*args)
    super
    self.layout = :vertical_box
  end

  ##############################################################################
  #
  # 
  #
  def resize(width, height, margin)
    super
    method(:"#{@layout}_resize").()
    update_collision
  end

  ##############################################################################
  #
  # 
  #
  def move(ox=0, oy=0)
    super
    method(:"#{@layout}_move").()
  end

  ##############################################################################
  #
  # 
  #
  def flow_resize
    v_margin = padding
    max_width = (@width or (image and image.width) or Window.width)
    @computed_width = max_width
    @computed_height = components.lazy.each {|component|
      component.resize(max_width, nil, padding)
    }.slice_before(
      &flow_slice(padding, 0, max_width)
    ).inject(0) {|height, row|
      component = row.max_by(&:layout_height)
      next height if component.position == :absolute
      v_space = [v_margin, component.margin].max + height
      v_margin = component.margin
      v_space + component.height
    } + [v_margin, padding].max
  end

  ##############################################################################
  #
  # 
  #
  def flow_move
    v_margin = padding
    max_width = (@width or (image and image.width) or Window.width)
    components.slice_before(
      &flow_slice(padding, 0, max_width)
    ).inject(0) {|height, row|
      component = row.max_by(&:layout_height)
      max_component_height = component.height
      v_space = [v_margin, component.margin].max + height
      v_margin = component.margin
      h_margin = padding
      row.inject(0) do |width, component|
        h_space = [h_margin, component.margin].max + width
        component.move(self.x + h_space, self.y + v_space + (max_component_height - component.height) / 2)
        next width if component.position == :absolute
        h_margin = component.margin
        h_space + component.width
      end
      v_space + max_component_height
    }
  end

  ##############################################################################
  #
  # コンテナ幅に収まる位置でコンポーネントを列に分割するための判定用ブロック.
  #
  # - Returns: Proc
  #
  def flow_slice(h_margin, width, max_width)
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
  private :flow_slice

  ##############################################################################
  #
  # 
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

  ##############################################################################
  #
  # 
  #
  def vertical_box_move
    v_margin = padding
    components.inject(0) do |height, component|
      v_space = [v_margin, component.margin].max + height
      component.move(self.x + [padding, component.margin].max, self.y + v_space)
      next height if component.position == :absolute
      v_margin = component.margin 
      v_space + component.height
    end
  end

  ##############################################################################
  #
  # 
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

  ##############################################################################
  #
  # 
  #
  def horizontal_box_move
    h_margin = padding
    components.inject(0) do |width, component|
      h_space = [h_margin, component.margin].max + width
      component.move(self.x + h_space, self.y + (self.height - component.height) / 2)
      next width if component.position == :absolute
      h_margin = component.margin
      h_space + component.width
    end
  end

end
