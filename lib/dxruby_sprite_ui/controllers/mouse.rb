require 'weakref'

class DXRuby::SpriteUI::Mouse < Sprite

  attr_reader :hover, :prev

  def initialize()
    @hover = nil
    self.collision = [0,0]
  end

  def update
    self.x = Input.mouse_x
    self.y = Input.mouse_y
  end

  def hover=(component)
    @hover = component
  end

  def left_push?
    Input.mouse_push?(M_LBUTTON)
  end

  def left_down?
    Input.mouse_down?(M_LBUTTON)
  end

  def left_release?
    Input.mouse_release?(M_LBUTTON)
  end

  def right_push?
    Input.mouse_push?(M_RBUTTON)
  end

  def right_down?
    Input.mouse_down?(M_RBUTTON)
  end

  def right_release?
    Input.mouse_release?(M_RBUTTON)
  end

  def middle_push?
    Input.mouse_push?(M_MBUTTON)
  end

  def middle_down?
    Input.mouse_down?(M_MBUTTON)
  end

  def middle_release?
    Input.mouse_release?(M_MBUTTON)
  end

end

class DXRuby::SpriteUI::MouseEventDispatcher

  include Quincite::UI::EventDispatcher

  attr_reader :mouse, :mouse_prev

  def initialize(event_listener)
    super
    @mouse = SpriteUI::Mouse.new
    @mouse_prev = SpriteUI::Mouse.new
    @event = MouseEvent.new
  end

  def update
    mouse_prev.x = mouse.x
    mouse_prev.y = mouse.y
    mouse.update
  end

  def mouse_move_from
    [mouse_prev.x, mouse_prev.y]
  end

  def mouse_move_to
    [mouse.x, mouse.y]
  end

  def mouse_move?
    mouse_move_from == mouse_move_to
  end

  def mouse_hover_change?
    not(mouse.left_down? or mouse.hover == mouse_prev.hover)
  end

  def dispatch
    target = event_listener.all(:desc).find(&:===.(mouse))
    unless mouse.left_down?
      mouse_prev.hover = mouse.hover
      mouse.hover = target and WeakRef.new(target)
    end
    event_listener.all(:desc).select(&:===.(mouse)).tap do |targets|
      if mouse.left_push?
        targets.any? do |current_target|
          event.fire(:mouse_left_push, target, current_target)
        end
      end
      if mouse.right_push?
        targets.any? do |current_target|
          event.fire(:mouse_right_push, target, current_target)
        end
      end
      if mouse.middle_push?
        targets.any? do |current_target|
          event.fire(:mouse_middle_push, current_target, target)
        end
      end
      if mouse.left_down?
        mouse.hover.activate if mouse.hover
        targets.any? do |current_target|
          event.fire(:mouse_left_down, current_target, target)
        end
      end
      if mouse.right_down?
        targets.any? do |current_target|
          event.fire(:mouse_right_down, current_target, target)
        end
      end
      if mouse.middle_down?
        targets.any? do |current_target|
          event.fire(:mouse_middle_down, current_target, target)
        end
      end
      if mouse.left_release?
        mouse_prev.hover.deactivate if mouse_prev.hover
        targets.any? do |current_target|
          event.fire(:mouse_left_release, current_target, target)
        end
      end
      if mouse.right_release?
        targets.any? do |current_target|
          event.fire(:mouse_right_release, current_target, target)
        end
      end
      if mouse.middle_release?
        targets.any? do |current_target|
          event.fire(:mouse_middle_release, current_target, target)
        end
      end
      if mouse_hover_change?
        event_listener.all(:desc).select(&:===.(mouse_prev.hover)).any? do |current_target|
          event.fire(:mouse_out, current_target, mouse_prev.hover, [mouse_prev.hover, mouse.hover])
        end
      end
      if mouse_move?
        targets.any? do |current_target|
          event.fire(:mouse_move, current_target, target, [mouse_move_from, mouse_move_to])
        end
      end
      if mouse_hover_change?
        targets.any? do |current_target|
          event.fire(:mouse_over, current_target, mouse.hover, [mouse_prev.hover, mouse.hover])
        end
      end
    end
  end

end
