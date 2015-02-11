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

    class StyleSet

      attr_reader :bg

      attr_accessor :border_width, :border_color
      attr_accessor :margin, :padding
      attr_accessor :width, :height
      attr_accessor :position, :top, :left
      attr_accessor :visible

      def initialize
        @margin = 0
        @padding = 0
        @bg = nil
        @border_width = 0
        @border_color = [0, 0, 0, 0]
        @width = nil
        @height = nil
        @position = :relative
        @top = 0
        @left = 0
        @visible = true
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

    end

    class Base < Sprite

      include SpriteUI
      include UI::Control

      extend Forwardable

      attr_accessor :id

      def_delegators :@style, :bg=, :border=
      def_delegators :@style, :position, :position=
      def_delegators :@style, :top, :top=, :left, :left=
      def_delegators :@style, :padding, :padding=

      def_delegators :@style, :width=, :height=, :margin=
      def_delegators :@style, :visible=, :visible?

      def initialize(id='', *args)
        super(0, 0)
        self.id = id
        self.collision = [0, 0]
        @style = StyleSet.new
        init_control
      end

      def width
        if @style.width
          @style.width
        elsif @computed_width
          @computed_width # + padding * 2
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
        if @style.height
          @style.height
        elsif @computed_height
          @computed_height # + padding * 2
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
          width + margin * 2
        end
      end

      def layout_height
        case position
        when :absolute
          0
        else
          height + margin * 2
        end
      end

      def margin
        case position
        when :absolute
          0
        else
          @style.margin
        end
      end

      def draw
        if visible?
          draw_bg if @style.bg
          draw_image(x + padding, y + padding) if image
          draw_border if @style.border_width and @style.border_color
        end
      end

      def draw_bg
        draw_scaled_image(x, y, @style.bg, scale_x: width, scale_y: height)
      end

      def draw_border
        draw_line(x,
                  y,
                  x + width - @style.border_width,
                  y,
                  @style.border_width,
                  @style.border_color)
        draw_line(x,
                  y + @style.border_width,
                  x,
                  y + height - @style.border_width,
                  @style.border_width,
                  @style.border_color)
        draw_line(x + @style.border_width,
                  y + height - @style.border_width,
                  x + width - @style.border_width,
                  y + height - @style.border_width,
                  @style.border_width,
                  @style.border_color)
        draw_line(x + width - @style.border_width,
                  y,
                  x + width - @style.border_width,
                  y + height - @style.border_width,
                  @style.border_width,
                  @style.border_color)
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
        move(ox, oy)
      end

      def move(to_x, to_y)
        self.x = to_x + left
        self.y = to_y + top
      end

      def resize
        self.collision = [0, 0, width, height]
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
        max_width = (@style.width or (image and image.width) or Window.width)
        width = 0
        adjacent_vertical_space = padding
        adjacent_horizontal_space = padding
        @computed_width = max_width
        @computed_height = components.slice_before {|component|
          horizontal_space = [adjacent_horizontal_space, component.margin].max
          component.resize
          if (component.position == :absolute)
            false
          else
            if width > 0 and width + component.layout_width > max_width - padding * 2
              width = horizontal_space + component.layout_width - component.margin * 2
              adjacent_horizontal_space = padding
              true
            else
              width += horizontal_space + component.layout_width - component.margin * 2
              adjacent_horizontal_space = component.margin
              false
            end
          end
        }.inject(0) {|height, row|
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
        max_width = (@style.width or (image and image.width) or Window.width)
        width = 0
        adjacent_vertical_space = padding
        adjacent_horizontal_space = padding
        components.slice_before {|component|
          horizontal_space = [adjacent_horizontal_space, component.margin].max
          if (component.position == :absolute)
            false
          else
            if width > 0 and width + component.layout_width > max_width - padding * 2
              width = horizontal_space + component.layout_width - component.margin * 2
              adjacent_horizontal_space = padding
              true
            else
              width += horizontal_space + component.layout_width - component.margin * 2
              adjacent_horizontal_space = component.margin
              false
            end
          end
        }.inject(0) {|height, row|
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

      def variable_width?
        @style.width.nil? and (image.nil? or image.width.zero?)
      end
      private :variable_width?

      def variable_height?
        @style.height.nil? and (image.nil? or image.height.zero?)
      end
      private :variable_height?

    end
  end
end
