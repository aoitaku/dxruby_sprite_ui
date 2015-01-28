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

      def layout(ox=0, oy=0, &block)
        self.x = ox + left
        self.y = oy + top
        yield if block_given?
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

      def layout(ox=0, oy=0)
        super(ox, oy) do
          height = components.inject(0) do |height, component|
            component.layout(self.x, self.y + height)
            height + component.layout_height
          end
          if @height.nil? and (image.nil? or image.height.zero?)
            @computed_height = height
          end
          if @width.nil? and (image.nil? or image.width.zero?)
            @computed_width = components.inject(0) do |width, component|
              [width, component.layout_width].max
            end
          end
        end
      end

    end
  end
end
