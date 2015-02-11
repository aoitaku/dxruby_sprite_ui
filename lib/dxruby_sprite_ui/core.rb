require 'dxruby'
require 'quincite'

module DXRuby

  module SpriteUI

    include Quincite

    def self.build(&proc)
      UI.build(UI::ContainerBox, &proc)
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
        if @style.height
          @style.height
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
        (target or Window).draw_scale(x, y, @style.bg, width, height, 0, 0)
      end

      def draw_border
        draw_box(x, y, x + width, y + height, @style.border_width, @style.border_color)
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

      def draw_box(x0, y0, x1, y1, width, color)
        draw_line(x0, y0, x1 - width, y0, width, color)
        draw_line(x0, y0, x0, y1 - width, width, color)
        draw_line(x0, y1 - width, x1 - width, y1 - width, width, color)
        draw_line(x1 - width, y0, x1 - width, y1 - width, width, color)
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

      def initialize(*args)
        super
        init_container
      end

      def draw
        super
        components.each(&:draw) if visible?
      end

      def update
        super
        components.each(&:update)
      end

    end
  end
end
