module CyberarmEngine
  class Text
    CACHE = {} of Int64 | Int32 | Float32 | Float64 => Hash(String, Gosu::Font)

    @gosu_font : Gosu::Font
    @cached_text_image : Gosu::Image?
    @cached_text_border_image : Gosu::Image?
    @cached_text_shadow_image : Gosu::Image?

    def initialize(@text : String = "", @size = 18, @font : String = Gosu.default_font_name,
                   @x = 0.0, @y = 0.0, @z = 1025.0, @factor_x = 1.0, @factor_y = 1.0,
                   @color : Gosu::Color | UInt32 = Gosu::Color::WHITE, @mode = :default, @static = false,
                   @border = false, @border_size = 1.0, @border_color : Gosu::Color | UInt32 = Gosu::Color::BLACK,
                   @shadow = false, @shadow_size = 1.0, @shadow_color : Gosu::Color | UInt32 = Gosu::Color::BLACK)
      @gosu_font = check_cache(@size, @font)
    end

    def check_cache(size, font_name) : Gosu::Font
      if CACHE.dig?(size)
        if font = CACHE.dig?(size, font_name)
          return font
        end
      end

      font = Gosu::Font.new(size, name: font_name)

      CACHE[size] ||= {} of String => Gosu::Font
      CACHE[size][font_name] = font

      return font
    end

    def swap_font(size, font_name = @font)
      return unless @size != size || @font != font_name

      @size = size
      @font = font_name

      @gosu_font = check_cache(size, font_name)
    end

    def text=(string)
      @cached_text_border_image = nil
      @text = string
    end

    def factor_x=(n)
      @cached_text_border_image = nil
      @factor_x = n
    end

    def factor_y=(n)
      @cached_text_border_image = nil
      @factor_y = n
    end

    def color=(color)
      @cached_text_border_image = nil
      @color = color
    end

    def border=(boolean : Bool)
      @cached_text_border_image = nil
      @border = boolean
    end

    def border_size=(n)
      @cached_text_border_image = nil
      @border_size = n
    end

    def border_color=(color)
      @cached_text_border_image = nil
      @border_color = color
    end

    def width(text = @text)
      markup_width(text)
    end

    def text_width(text = @text)
      @gosu_font.text_width(text) + @border_size + @shadow_size
    end

    def markup_width(text = @text)
      @gosu_font.markup_width(text) + @border_size + @shadow_size
    end

    def height(text = @text)
      if text.lines.size > 0
        text.lines.size * @gosu_font.height + @border_size + @shadow_size
      else
        @gosu_font.height + @border_size + @shadow_size
      end
    end

    def draw(text = @text)
      if @gosu_font
        if @static
          @cached_text_border_image.not_nil!.draw(@x, @y, @z, @factor_x, @factor_y, @border_color, @mode) if @cached_text_border_image

          @cached_text_shadow_image.not_nil!.draw(@x + @shadow_size, @y + @shadow_size, @z, @factor_x, @factor_y, @shadow_color, @mode) if @cached_text_shadow_image

          @gosu_cached_text_image.not_nil!.draw(@x, @y, @z, @factor_x, @factor_y, @color, @mode) if @gosu_cached_text_image
        else
          if @border
            _x = @border_size
            _y = @border_size
            _width = markup_width

            @gosu_font.draw_markup(text, @x - _x, @y, @z, @factor_x, @factor_y, @border_color, @mode)
            @gosu_font.draw_markup(text, @x - _x, @y - _y, @z, @factor_x, @factor_y, @border_color, @mode)

            @gosu_font.draw_markup(text, @x, @y - _y, @z, @factor_x, @factor_y, @border_color, @mode)
            @gosu_font.draw_markup(text, @x + _x, @y - _y, @z, @factor_x, @factor_y, @border_color, @mode)

            @gosu_font.draw_markup(text, @x + _x, @y, @z, @factor_x, @factor_y, @border_color, @mode)
            @gosu_font.draw_markup(text, @x + _x, @y + _y, @z, @factor_x, @factor_y, @border_color, @mode)

            @gosu_font.draw_markup(text, @x, @y + _y, @z, @factor_x, @factor_y, @border_color, @mode)
            @gosu_font.draw_markup(text, @x - _x, @y + _y, @z, @factor_x, @factor_y, @border_color, @mode)
          end

          @gosu_font.draw_markup(text, @x + @shadow_size, @y + @shadow_size, @z, @factor_x, @factor_y, @shadow_color, @mode) if @shadow

          @gosu_font.draw_markup(text, @x, @y, @z, @factor_x, @factor_y, @color, @mode)
        end
      end
    end

    def update
      if @static
        unless @cached_text_border_image
          _x = @border_size
          _y = @border_size
          _width = markup_width(@text)
          img = Gosu::Image.from_markup(@text, @size, @font)

          @cached_text_border_image = Gosu.render((_width + (@border_size * 2)).ceil.to_i, (height + (@border_size * 2)).ceil.to_i) do
            img.draw(-_x, 0, @z, @factor_x, @factor_y, @border_color, @mode)
            img.draw(-_x, -_y, @z, @factor_x, @factor_y, @border_color, @mode)

            img.draw(0, -_y, @z, @factor_x, @factor_y, @border_color, @mode)
            img.draw(_x, -_y, @z, @factor_x, @factor_y, @border_color, @mode)

            img.draw(_x, 0, @z, @factor_x, @factor_y, @border_color, @mode)
            img.draw(_x, _y, @z, @factor_x, @factor_y, @border_color, @mode)

            img.draw(0, _y, @z, @factor_x, @factor_y, @border_color, @mode)
            img.draw(-_x, _y, @z, @factor_x, @factor_y, @border_color, @mode)
          end
        end

        @cached_text_shadow_image = Gosu::Image.from_markup(@text, @size, @font) unless @cached_text_shadow_image

        @gosu_cached_text_image = Gosu::Image.from_markup(@text, @size, @font) unless @cached_text_image
      end
    end
  end
end
