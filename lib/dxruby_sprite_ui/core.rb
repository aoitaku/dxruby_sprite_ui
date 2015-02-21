################################################################################
#
# SpriteUI
#
# Author:  aoitaku
# Licence: zlib/libpng
#
################################################################################

require 'dxruby'
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
      UI.build(UI::ContainerBox, &proc)
    end

    ############################################################################
    #
    # SpriteUI にモジュールを割り当てる.
    #
    def self.equip(mod)
      Base.__send__(:include, const_get(mod))
    end

    ############################################################################
    #
    # ColorUtils モジュール
    #
    module ColorUtils

      ##########################################################################
      #
      # 引数を色配列を生成する.
      #
      # Params:
      #   - color :
      #
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

    ############################################################################
    #
    # StyleSet クラス.
    #
    class StyleSet

      # 
      #
      attr_reader :bg

      # 
      #
      attr_accessor :border_width, :border_color
      attr_accessor :margin, :padding
      attr_accessor :width, :height
      attr_accessor :position, :top, :left
      attr_accessor :visible

      ##########################################################################
      #
      # 初期化.
      #
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

      ##########################################################################
      #
      # 背景色を設定する.
      #
      def bgcolor=(bgcolor)
        bgcolor = ColorUtils.make_color(bgcolor)
        if bgcolor
          @bg = Image.new(1, 1, bgcolor)
        else
          @bg = nil
        end
      end

      ##########################################################################
      #
      # 枠線を設定する.
      #
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

      ##########################################################################
      #
      # 可視状態を取得する.
      #
      # Returns:
      # 
      #
      def visible?
        @visible
      end

    end

    ############################################################################
    #
    # Base クラス
    #
    class Base < Sprite

      include SpriteUI
      include UI::Control

      extend Forwardable

      # 
      #
      attr_accessor :id

      # 
      #
      attr_reader :style

      # 
      #
      def_delegators :@style, :position
      def_delegators :@style, :top, :left
      def_delegators :@style, :padding
      def_delegators :@style, :visible?

      ##########################################################################
      #
      # 初期化.
      #
      def initialize(id='', *args)
        super(0, 0)
        self.id = id
        self.collision = [0, 0]
        @style = StyleSet.new
        init_control
      end

      ##########################################################################
      #
      # 指定された名前のスタイルが存在するか判定を行う.
      #
      # Params:
      #   - name :
      #
      # Returns:
      #   
      #
      def style_include?(name)
        @style.respond_to?("#{name}=")
      end

      ##########################################################################
      #
      # スタイルを設定する.
      #
      # Params:
      #   - name :
      #   - args :
      #
      def style_set(name, args)
        @style.__send__("#{name}=", args)
      end

      ##########################################################################
      #
      # コンポーネントの幅を取得する.
      #
      def width
        if @width
          @width
        elsif @computed_width
          @computed_width
        else
          content_width
        end
      end

      ##########################################################################
      #
      # 内容物に応じた幅を取得する.
      #
      def content_width
        if image
          image.width
        else
          0
        end
      end

      ##########################################################################
      #
      # コンポーネントの高さを取得する.
      #
      def height
        if @height
          @height
        elsif @computed_height
          @computed_height
        else
          content_height
        end
      end

      ##########################################################################
      #
      # 内容物に応じた高さを取得する.
      #
      def content_height
        if image
          image.height
        else
          0
        end
      end

      ##########################################################################
      #
      # 配置上のコンポーネントの幅を取得する.
      #
      def layout_width
        case position
        when :absolute
          0
        else
          width + margin * 2
        end
      end

      ##########################################################################
      #
      # 配置上のコンポーネントの高さを取得する.
      #
      def layout_height
        case position
        when :absolute
          0
        else
          height + margin * 2
        end
      end

      ##########################################################################
      #
      # コンポーネントの外側の余白を取得する.
      #
      def margin
        case position
        when :absolute
          0
        else
          @style.margin
        end
      end

      ##########################################################################
      #
      # コンポーネントの描画.
      #
      def draw
        if visible?
          draw_bg if @style.bg
          draw_image(x + padding, y + padding) if image
          draw_border if @style.border_width and @style.border_color
        end
      end

      ##########################################################################
      #
      # 背景を描画する.
      #
      def draw_bg
        (target or Window).draw_scale(x, y, @style.bg, width, height, 0, 0)
      end

      ##########################################################################
      #
      # 枠線を描画する.
      #
      def draw_border
        draw_box(x, y, x + width, y + height, @style.border_width, @style.border_color)
      end

      ##########################################################################
      #
      # 画像を描画する.
      #
      def draw_image(x, y)
        (target or Window).draw(x, y, image)
      end

      ##########################################################################
      #
      # 直線を描画する.
      #
      def draw_line(x0, y0, x1, y1, width, color)
        if width == 1
          (target or Window).draw_line(x0, y0, x1 + width - 1, y1 + width - 1, color)
        else
          (target or Window).draw_box_fill(x0, y0, x1 + width - 1, y1 + width - 1, color)
        end
      end

      ##########################################################################
      #
      # 矩形の境界線を描画する.
      #
      def draw_box(x0, y0, x1, y1, width, color)
        draw_line(x0, y0, x1 - width, y0, width, color)
        draw_line(x0, y0, x0, y1 - width, width, color)
        draw_line(x0, y1 - width, x1 - width, y1 - width, width, color)
        draw_line(x1 - width, y0, x1 - width, y1 - width, width, color)
      end

      ##########################################################################
      #
      # コンポーネントの更新.
      #
      def update
      end

      ##########################################################################
      #
      # コンポーネントの配置.
      #
      def layout(ox=0, oy=0)
        resize(width || Window.width, height || Window.height, 0)
        move(ox, oy)
      end

      ##########################################################################
      #
      # コンポーネントの座標の更新.
      #
      def move(to_x, to_y)
        self.x = to_x + left
        self.y = to_y + top
      end

      ##########################################################################
      #
      # コンポーネントの領域の更新.
      #
      def resize(width, height, margin)
        case @style.width
        when Integer
          @width = @style.width
        when Float
          @width = width * @style.width
        when :full
          @width = width - [margin, self.margin].max * 2
        else
          @width = nil
        end
        case @style.height
        when Integer
          @height = @style.height
        when Float
          @height = height * @style.height
        when :full
          @height = height - [margin, self.margin].max * 2
        else
          @height = nil
        end
      end

      ##########################################################################
      #
      # 接触判定領域の更新.
      #
      def update_collision
        self.collision = [0, 0, self.width, self.height]
      end

    end

    ############################################################################
    #
    # Container クラス.
    #
    class Container < Base

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
