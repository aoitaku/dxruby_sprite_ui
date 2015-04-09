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
      attr_reader :margin, :padding

      # 
      #
      attr_accessor :border_width, :border_color
      attr_accessor :width, :height
      attr_accessor :position, :top, :left, :bottom, :right
      attr_accessor :visible
      attr_accessor :break_after

      ##########################################################################
      #
      # 初期化.
      #
      def initialize
        @margin = [0, 0, 0, 0]
        @padding = [0, 0, 0, 0]
        @bg = nil
        @border_width = 0
        @border_color = [0, 0, 0, 0]
        @width = nil
        @height = nil
        @position = :relative
        @top = nil
        @left = nil
        @bottom = nil
        @right = nil
        @visible = true
        @break_after = false
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
      # マージンを設定する.
      #
      def margin=(args)
        case args
        when Numeric
          @margin = [args] * 4
        when Array
          case args.size
          when 1
            @margin = args * 4
          when 2
            @margin = args * 2
          when 3
            @margin = [*args, args[1]]
          when 4
            @margin = args
          else
            @margin = args[0...4]
          end
        else
          @margin = [0, 0, 0, 0]
        end
      end

      ##########################################################################
      #
      #
      #
      def margin_top
        @margin[0]
      end

      ##########################################################################
      #
      #
      #
      def margin_right
        @margin[1]
      end

      ##########################################################################
      #
      #
      #
      def margin_bottom
        @margin[2]
      end

      ##########################################################################
      #
      #
      #
      def margin_left
        @margin[3]
      end

      ##########################################################################
      #
      # パディングを設定する.
      #
      def padding=(args)
        case args
        when Numeric
          @padding = [args] * 4
        when Array
          case args.size
          when 1
            @padding = args * 4
          when 2
            @padding = args * 2
          when 3
            @padding = [*args, args[1]]
          when 4
            @padding = args
          else
            @padding = args[0...4]
          end
        else
          @padding = [0, 0, 0, 0]
        end
      end

      ##########################################################################
      #
      #
      #
      def padding_top
        @padding[0]
      end

      ##########################################################################
      #
      #
      #
      def padding_right
        @padding[1]
      end

      ##########################################################################
      #
      #
      #
      def padding_bottom
        @padding[2]
      end

      ##########################################################################
      #
      #
      #
      def padding_left
        @padding[3]
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

      ##########################################################################
      #
      # ブレークポイントの有無を取得する.
      #
      # Returns:
      # 
      #
      def break_after?
        @break_after
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
      def_delegators :@style, :top, :left, :bottom, :right
      def_delegators :@style, :padding_top, :padding_bottom
      def_delegators :@style, :padding_left, :padding_right
      def_delegators :@style, :bg
      def_delegators :@style, :border_width, :border_color
      def_delegators :@style, :visible?
      def_delegators :@style, :break_after?

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
          width + margin_left + margin_right
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
          height + margin_top + margin_bottom
        end
      end

      ##########################################################################
      #
      # コンポーネントの外側の余白を取得する.
      #
      def margin_top
        case position
        when :absolute
          0
        else
          @style.margin_top
        end
      end

      ##########################################################################
      #
      # コンポーネントの外側の余白を取得する.
      #
      def margin_right
        case position
        when :absolute
          0
        else
          @style.margin_right
        end
      end

      ##########################################################################
      #
      # コンポーネントの外側の余白を取得する.
      #
      def margin_bottom
        case position
        when :absolute
          0
        else
          @style.margin_bottom
        end
      end

      ##########################################################################
      #
      # コンポーネントの外側の余白を取得する.
      #
      def margin_left
        case position
        when :absolute
          0
        else
          @style.margin_left
        end
      end

      ##########################################################################
      #
      # コンポーネントの描画.
      #
      def draw
        if visible?
          draw_bg if bg
          draw_image(x + padding_left, y + padding_top) if image
          draw_border if border_width and border_color
        end
      end

      ##########################################################################
      #
      # 背景を描画する.
      #
      def draw_bg
        (target or Window).draw_scale(x, y, bg, width, height, 0, 0)
      end

      ##########################################################################
      #
      # 枠線を描画する.
      #
      def draw_border
        draw_box(x, y, x + width, y + height, border_width, border_color)
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
        x1 += width - 1
        y1 += width - 1
        if width == 1
          (target or Window).draw_line(x0, y0, x1, y1, color)
        else
          (target or Window).draw_box_fill(x0, y0, x1, y1, color)
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
      def layout(ox=0, oy=0, parent=DXRuby::Window)
        resize(parent)
        move(ox, oy, parent)
      end

      ##########################################################################
      #
      # コンポーネント内部の幅を取得する.
      #
      def inner_width(parent)
        if parent == DXRuby::Window
          parent.width - (self.margin_left + self.margin_right)
        else
          parent.width -
            ([parent.padding_left, self.margin_left].max +
             [parent.padding_right, self.margin_right].max)
        end
      end

      ##########################################################################
      #
      # コンポーネント内部の高さを取得する.
      #
      def inner_height(parent)
        if parent == DXRuby::Window 
          parent.height - (self.margin_top + self.margin_bottom)
        else
          parent.height -
            ([parent.padding_top, self.margin_top].max +
             [parent.padding_bottom, self.margin_bottom].max)
        end
      end

      ##########################################################################
      #
      # コンポーネントの座標の更新.
      #
      def move(to_x, to_y, parent)
        move_x(to_x, parent)
        move_y(to_y, parent)
      end

      ##########################################################################
      #
      # コンポーネントの x 座標の更新.
      #
      # Private
      #
      def move_x(to_x, parent)
        if position == :absolute
          if left and Numeric === left
            case left
            when Fixnum
              self.x = to_x + left
            when Float
              self.x = to_x + (parent.width - self.width) * left
            end
          elsif right and Numeric === right
            case left
            when Fixnum
              self.x = to_x + parent.width - self.width - right
            when Float
              self.x = to_x + (parent.width - self.width) * (right - 1)
            end
          else
            self.x = to_x
          end
        else
          if left and Numeric === left
            self.x = to_x + left
          elsif right and Numeric === right
            self.x = to_x + inner_width(parent) - self.width - right
          else
            self.x = to_x
          end
        end
      end
      private :move_x

      ##########################################################################
      #
      # コンポーネントの y 座標の更新.
      #
      # Private
      #
      def move_y(to_y, parent)
        if position == :absolute
          if top and Numeric === top
            case top
            when Fixnum
              self.y = to_y + top
            when Float
              self.y = to_y + (parent.height - self.height) * top
            end
          elsif bottom and Numeric === bottom
            case bottom
            when Fixnum
              self.y = to_y + parent.height - self.height - bottom
            when Float
              self.y = to_y + (parent.height - self.height) * (bottom - 1)
            end
          else
            self.y = to_y
          end
        else
          if top and Numeric === top
            self.y = to_y + top
          elsif bottom and Numeric === bottom
            self.y = to_y + inner_height(parent) - self.height - bottom
          else
            self.y = to_y
          end
        end
      end
      private :move_y

      ##########################################################################
      #
      # コンポーネントの領域の更新.
      #
      def resize(parent)
        case @style.width
        when Integer
          @width = @style.width
        when Float
          @width = parent.width * @style.width
        when :full
          @width = inner_width(parent)
        else
          @width = nil
        end
        case @style.height
        when Integer
          @height = @style.height
        when Float
          @height = parent.height * @style.height
        when :full
          @height = inner_height(parent)
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
