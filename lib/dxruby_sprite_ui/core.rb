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

    module ColorUtils

      def self.make_color(color)
        case color
        when Array
          color
        when Fixnum
          [color >> 16 & 0xff,
           color >> 8 & 0xff,
           color & 0xff]
        when /^#[0-9a-fA-F]{6}$/
          [color[1..2].hex,
           color[3..4].hex,
           color[5..6].hex]
        else
          nil
        end
      end

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
        @border = nil
        @bg = nil
        init_control
      end

      def bgcolor=(bgcolor)
        bgcolor = ColorUtils.make_color(bgcolor)
        if bgcolor
          @bg = Image.new(1, 1, bgcolor)
        else
          @bg = nil
        end
      end

      def border=(border)
        case border
        when Hash
          @border_width = border[:width] || 1
          @border_color = ColorUtils.make_color(border[:color]) || [255, 255, 255]
        else
          @border_width = nil
          @border_color = nil
        end
      end

      def visible?
        @visible
      end

      def width
        if @width
          @width
        elsif @computed_width
          @computed_width + padding * 2
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
          @computed_height + padding * 2
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
        if visible?
          draw_bg if @bg
          draw_image(x + padding, y + padding) if image
          draw_border if @border_width and @border_color
        end
      end

      def draw_bg
        draw_scaled_image(x, y, @bg, scale_x: width, scale_y: height)
      end

      def draw_border
        draw_line(x,
                  y,
                  x + width - @border_width,
                  y,
                  @border_width,
                  @border_color
        )
        draw_line(x,
                  y + @border_width,
                  x,
                  y + height - @border_width,
                  @border_width,
                  @border_color
        )
        draw_line(x + @border_width,
                  y + height - @border_width,
                  x + width - @border_width,
                  y + height - @border_width,
                  @border_width,
                  @border_color)
        draw_line(x + width - @border_width,
                  y,
                  x + width - @border_width,
                  y + height - @border_width,
                  @border_width,
                  @border_color)
      end

      def draw_image(x, y)
        (target or Window).draw(x, y, image)
      end

      def draw_line(x0, y0, x1, y1, width, color)
        if width == 1
          (target or Window).draw_line(x0, y0, x1 + width - 1, y1 + width - 1, color)
        else
          (target or Window).draw_box_fill(x0, y0, x1 + width - 1, y1 + width - 1, color)
        end
      end

      def draw_scaled_image(x, y, image, scale_x: 1, scale_y: 1)
        (target or Window).draw_scale(x, y, image, scale_x, scale_y, 0, 0)
      end

      def update
      end

      def layout(ox=0, oy=0)
        resize
        move(ox + left, oy + top)
        self.collision = [0, 0, width, height]
      end

      def move(to_x, to_y)
        self.x = to_x
        self.y = to_y
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
        max_width = (@width or (image and image.width) or Window.width) - padding * 2
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
        max_width = (@width or (image and image.width) or Window.width) - padding * 2
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
            component.move(
              self.x + padding + width,
              self.y + padding + height + (max_height - component.layout_height) / 2
            )
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
          component.move(
            self.x + padding, self.y + padding + height
          )
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
          component.move(
            self.x + padding + width,
            self.y + (self.height - component.layout_height) / 2
          )
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
