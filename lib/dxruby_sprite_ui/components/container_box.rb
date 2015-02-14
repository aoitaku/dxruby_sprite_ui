class Quincite::UI::ContainerBox < DXRuby::SpriteUI::Container

  attr_writer :layout

  def initialize(*args)
    super
    self.layout = :vertical_box
  end

  def resize(width, height, margin)
    super
    method(:"#{@layout}_resize").()
    update_collision
  end

  def move(ox=0, oy=0)
    super
    method(:"#{@layout}_move").()
  end

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
      v_space = [v_margin, component.margin].max + height
      if component.position == :absolute
        height
      else
        v_margin = component.margin
        v_space + component.height
      end
    } + [v_margin, padding].max
  end

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
      row.inject(0) {|width, component|
        h_space = [h_margin, component.margin].max + width
        component.move(
          self.x + h_space,
          self.y + v_space + (max_component_height - component.height) / 2
        )
        if component.position == :absolute
          width
        else
          h_margin = component.margin
          h_space + component.width
        end
      }
      v_space + max_component_height
    }
  end

  def flow_slice(h_margin, width, max_width)
    -> component {
      h_space = [h_margin, component.margin].max + component.width
      next false if component.position == :absolute
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

  def vertical_box_resize
    v_margin = padding
    component = components.max_by(&:layout_width)
    @computed_width = component.width + [component.margin, padding].max * 2
    @computed_height = components.inject(0) {|height, component|
      v_space = [v_margin, component.margin].max + height
      component.resize(@computed_width, nil, padding)
      if component.position == :absolute
        height
      else
        v_margin = component.margin 
        v_space + component.height
      end
    } + [v_margin, padding].max
  end

  def vertical_box_move
    v_margin = padding
    components.inject(0) {|height, component|
      v_space = [v_margin, component.margin].max + height
      component.move(
        self.x + [padding, component.margin].max,
        self.y + v_space
      )
      if component.position == :absolute
        height
      else
        v_margin = component.margin 
        v_space + component.height
      end
    }
  end

  def horizontal_box_resize
    h_margin = padding
    component = components.max_by(&:layout_width)
    @computed_height = component.height + [component.margin, padding].max * 2
    @computed_width = components.inject(0) {|width, component|
      h_space = [h_margin, component.margin].max + width
      component.resize(nil, @computed_height, padding)
      if component.position == :absolute
        width
      else
        h_margin = component.margin
        h_space + component.width
      end
    } + [h_margin, padding].max
  end

  def horizontal_box_move
    h_margin = padding
    components.inject(0) {|width, component|
      h_space = [h_margin, component.margin].max + width
      component.move(
        self.x + h_space,
        self.y + (self.height - component.height) / 2
      )
      if component.position == :absolute
        width
      else
        h_margin = component.margin
        h_space + component.width
      end
    }
  end

end
