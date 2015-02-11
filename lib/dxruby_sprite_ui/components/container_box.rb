class Quincite::UI::ContainerBox < DXRuby::SpriteUI::Container

  attr_writer :layout

  def initialize(*args)
    super
    self.layout = :vertical_box
  end

  def resize
    super
    method(:"#{@layout}_resize").()
  end

  def move(ox=0, oy=0)
    super
    method(:"#{@layout}_move").()
  end

  def flow_resize
    adjacent_vertical_space = padding
    @computed_width = (@style.width or (image and image.width) or Window.width)
    @computed_height = flow_slice(true).inject(0) {|height, row|
      component = row.max_by(&:layout_height)
      vertical_space = [adjacent_vertical_space, component.margin].max
      if component.position == :absolute
        height
      else
        adjacent_vertical_space = component.margin
        height + vertical_space + component.layout_height - component.margin * 2
      end
    } + [adjacent_vertical_space, padding].max
  end

  def flow_move
    adjacent_vertical_space = padding
    flow_slice.inject(0) {|height, row|
      component = row.max_by(&:layout_height)
      max_height = component.layout_height
      vertical_space = [adjacent_vertical_space, component.margin].max
      adjacent_vertical_space = component.margin
      adjacent_horizontal_space = padding
      row.inject(0) {|width, component|
        horizontal_space = [adjacent_horizontal_space, component.margin].max
        if component.position == :absolute
          component.move(
            self.x + horizontal_space + width,
            self.y + vertical_space - adjacent_vertical_space + height + (max_height - component.height) / 2
          )
          width
        else
          component.move(
            self.x + horizontal_space + width,
            self.y + vertical_space + height + (max_height - component.layout_height) / 2
          )
          adjacent_horizontal_space = component.margin
          width + horizontal_space + component.layout_width - component.margin * 2
        end
      }
      height + vertical_space + max_height - component.margin * 2
    }
  end

  def flow_slice(with_resize=false)
    max_width = (@style.width or (image and image.width) or Window.width)
    width = 0
    adjacent_space = padding
    components.slice_before {|component|
      space = [adjacent_space, component.margin].max
      component.resize if with_resize
      if (component.position == :absolute)
        false
      else
        if width > 0 and width + component.layout_width > max_width - padding * 2
          width = space + component.layout_width - component.margin * 2
          adjacent_space = padding
          true
        else
          width += space + component.layout_width - component.margin * 2
          adjacent_space = component.margin
          false
        end
      end
    }
  end

  def vertical_box_resize
    width = 0
    adjacent_space = padding
    horizontal_space = 0
    @computed_height = components.inject(0) {|height, component|
      vertical_space = [adjacent_space, component.margin].max
      component.resize
      if width < component.layout_width
        width = component.layout_width
        horizontal_space = component.margin
      end
      if component.position == :absolute
        height
      else
        adjacent_space = component.margin 
        height + vertical_space + component.layout_height - component.margin * 2
      end
    } + [adjacent_space, padding].max
    @computed_width = width - horizontal_space * 2 + [horizontal_space, padding].max * 2
  end

  def vertical_box_move
    adjacent_space = padding
    components.inject(0) {|height, component|
      vertical_space = [adjacent_space, component.margin].max
      component.move(
        self.x + [padding, component.margin].max,
        self.y + vertical_space + height
      )
      if component.position == :absolute
        height
      else
        adjacent_space = component.margin 
        height + vertical_space + component.layout_height - component.margin * 2
      end
    }
  end

  def horizontal_box_resize
    height = 0
    adjacent_space = padding
    vertical_space = 0
    @computed_width = components.inject(0) {|width, component|
      horizontal_space = [adjacent_space, component.margin].max
      component.resize
      if height < component.layout_height
        height = component.layout_height
        vertical_space = component.margin
      end
      if component.position == :absolute
        width
      else
        adjacent_space = component.margin
        width + horizontal_space + component.layout_width - component.margin * 2
      end
    } + [adjacent_space, padding].max
    @computed_height = height - vertical_space + [vertical_space, padding].max * 2
  end

  def horizontal_box_move
    adjacent_space = padding
    components.inject(0) {|width, component|
      horizontal_space = [adjacent_space, component.margin].max
      vertical_space = [padding, component.margin].max
      if component.position == :absolute
        component.move(
          self.x + horizontal_space + width,
          self.y + (self.height - component.height) / 2
        )
        width
      else
        component.move(
          self.x + horizontal_space + width,
          self.y + (self.height - component.layout_height - vertical_space) / 2 + vertical_space
        )
        adjacent_space = component.margin
        width + horizontal_space + component.layout_width - component.margin * 2
      end
    }
  end

end
