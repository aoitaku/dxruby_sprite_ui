require 'dxruby'
require 'quincite'

module DXRuby

  module SpriteUI

    include Quincite

    def self.build(&proc)
      UI.build(Container, &proc)
    end

    def self.equip(mod)
      Base.__send__(:include, const_get(mod))
    end

    class Base < Sprite

      include SpriteUI
      include UI::Control

      attr_accessor :id
      attr_accessor :position, :top, :left
      attr_accessor :margin, :padding

      attr_writer :width, :height, :visible

      def initialize(id='', *args)
        super(0, 0)
        self.id = id
        self.position = :relative
        self.visible = true
        self.top = 0
        self.left = 0
        self.margin = 0
        self.padding = 0
        init_control
      end

      def visible?
        @visible
      end

      def width
        if @width
          @width
        elsif @computed_width
          @computed_width
        else
          content_width
        end
      end

      def content_width
        if image
          image.width
        else
          0
        end
      end

      def height
        if @height
          @height
        elsif @computed_height
          @computed_height
        else
          content_height
        end
      end

      def content_height
        if image
          image.height
        else
          0
        end
      end

      def layout_width
        case position
        when :absolute
          0
        else
          width
        end
      end

      def layout_height
        case position
        when :absolute
          0
        else
          height
        end
      end

      def draw
        draw_image(x, y, image) if visible?
      end

      def draw_image(x, y, image)
        (target or Window).draw(x, y, image) if image
      end

      def update
      end

      def layout(ox=0, oy=0)
        resize
        move(ox, oy)
        self.collision = [0, 0, width, height]
      end

      def move(ox=0, oy=0)
        self.x = ox + left
        self.y = oy + top
      end

      def resize
      end

    end

    class Container < Base

      include UI::Container

      attr_writer :layout

      def initialize(*args)
        super
        init_container
        self.layout = :vertical_box
      end

      def draw
        super
        components.each(&:draw) if visible?
      end

      def update
        super
        components.each(&:update)
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
        max_width = (@width or (image and image.width) or Window.width)
        width = 0
        @computed_width = max_width
        @computed_height = components.slice_before {|component|
          component.resize
          if width > 0 and width + component.layout_width > max_width
            width = component.layout_width
            true
          else
            width += component.layout_width
            false
          end
        }.inject(0) {|height, row|
          height + row.max_by(&:layout_height).layout_height
        }
      end

      def flow_move
        max_width = (@width or (image and image.width) or Window.width)
        width = 0
        components.slice_before {|component|
          if width > 0 and width + component.layout_width > max_width
            width = component.layout_width
            true
          else
            width += component.layout_width
            false
          end
        }.inject(0) {|height, row|
          max_height = row.max_by(&:layout_height).layout_height
          row.inject(0) {|width, component|
            component.move(self.x + width, self.y + height + (max_height - component.layout_height) / 2)
            width + component.layout_width
          }
          height + max_height
        }
      end

      def vertical_box_resize
        width = 0
        @computed_height = components.inject(0) {|height, component|
          component.resize
          width = component.layout_width if width < component.layout_width
          height + component.layout_height
        }
        @computed_width = width
      end

      def vertical_box_move
        components.inject(0) {|height, component|
          component.move(self.x, self.y + height)
          height + component.layout_height
        }
      end

      def horizontal_box_resize
        height = 0
        @computed_width = components.inject(0) {|width, component|
          component.resize
          height = component.layout_height if height < component.layout_height
          width + component.layout_width
        }
        @computed_height = height
      end

      def horizontal_box_move
        components.inject(0) {|width, component|
          component.move(self.x + width, self.y)
          width + component.layout_width
        }
      end

      def variable_width?
        @width.nil? and (image.nil? or image.width.zero?)
      end
      private :variable_width?

      def variable_height?
        @height.nil? and (image.nil? or image.height.zero?)
      end
      private :variable_height?

    end
  end
end
