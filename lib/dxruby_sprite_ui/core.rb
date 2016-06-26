################################################################################
#
# SpriteUI
#
# Author:  aoitaku
# Licence: zlib/libpng
#
################################################################################

require 'dxruby'
require 'forwardable'
require 'quincite'

module DXRuby

  ##############################################################################
  #
  # SpriteUI モジュール.
  #
  module SpriteUI

    include Quincite

    ############################################################################
    #
    # ビルダー DSL を実行して UI ツリーを構築する.
    #
    def self.build(&proc)
      Quincite::UI.max_width = Window.width
      Quincite::UI.max_height = Window.height

      UI.build(UI::ContainerBox, &proc)
    end

    ############################################################################
    #
    # SpriteUI にモジュールを割り当てる.
    #
    def self.equip(mod)
      Component.__send__(:include, const_get(mod))
    end

    class Component < Sprite

      include SpriteUI
      include UI::Component
      include UI::Control

      def initialize(id='', *args)
        super(0, 0)
        init_component
        init_control
        self.id = id
        self.collision = [0, 0]
      end

      def update
      end

      def update_collision
        self.collision = [0, 0, self.width, self.height]
      end

      def draw
        if visible?
          draw_bg if bg_image
          draw_image(x, y) if image
          draw_border if border_width and border_color
        end
      end

      def draw_bg
        (target or Window).draw_scale(x, y, bg_image, width, height, 0, 0)
      end

      def draw_border
        draw_box(x, y, x + width, y + height, border_width, [
          border_color.alpha,
          border_color.red,
          border_color.green,
          border_color.blue
        ])
      end

      def draw_image(x, y)
        (target or Window).draw(x, y, image)
      end

      def draw_line(x0, y0, x1, y1, width, color)
        x1 += width - 1
        y1 += width - 1
        if width == 1
          (target or Window).draw_line(x0, y0, x1, y1, color)
        else
          (target or Window).draw_box_fill(x0, y0, x1, y1, color)
        end
      end

      def draw_box(x0, y0, x1, y1, width, color)
        draw_line(x0, y0, x1 - width, y0, width, color)
        draw_line(x0, y0, x0, y1 - width, width, color)
        draw_line(x0, y1 - width, x1 - width, y1 - width, width, color)
        draw_line(x1 - width, y0, x1 - width, y1 - width, width, color)
      end

    end

    ############################################################################
    #
    # Container クラス.
    #
    class Container < Component

      include UI::Container

      ##########################################################################
      #
      # 初期化.
      #
      def initialize(*args)
        super
        init_container
      end

      ##########################################################################
      #
      # コンポーネントの描画.
      #
      def draw
        super
        components.each(&:draw) if visible?
      end

      ##########################################################################
      #
      # コンポーネントの更新.
      #
      def update
        super
        components.each(&:update)
      end

    end

  end
end
