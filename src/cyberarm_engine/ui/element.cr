module CyberarmEngine
  class Element
    def initialize(@parent, @gui_state : CyberarmEngine::GuiState, @style = StyleManager.new(StyleManager::DEFAULT_STYLES), @tag : String? = nil, @tip : String = "", &@block)
      @focus = true
      @enabled = true
      @visible = true
      @element_visible = true

      @debug_color = Gosu::Color::RED

      @width = 0
      @height = 0

      @style_event = :default

      @style.stylize

      default_events

      gui_state.request_focus(style) if @style.autofocus?
    end

    def default_events
      %i[left middle right].each do |button|
        event(:"#{button}_mouse_button")
        event(:"released_#{button}_mouse_button")
        event(:"clicked_#{button}_mouse_button")
        event(:"holding_#{button}_mouse_button")
      end

      event(:mouse_wheel_up)
      event(:mouse_wheel_down)

      event(:enter)
      event(:hover)
      event(:leave)

      event(:focus)
      event(:blur)

      event(:changed)
    end

    def enter(sender)
      @style.focus = false unless Gosu.button_down?(Gosu::MS_LEFT)

      @style.stylize

      :handled
    end

    def left_mouse_button(sender, x, y)
      @style.focus = true

      @style.stylize

      @gui_state.focus = self

      :handled
    end

    def released_left_mouse_button(sender, x, y)
      @block.not_nil!.call(self) if @block && @enabled && !is_a?(Container)

      :handled
    end

    def leave(sender)
      @style.stylize

      :handled
    end

    def blur
      @style.focus = false

      @style.stylize

      :handled
    end

    def enabled=(boolean : Bool)
      @style.enabled = boolean

      recalculate

      @style.enabled?
    end

    def enabled?
      @style.enabled?
    end

    def visible?
      @style.visible?
    end

    def element_visible?
      @element_visible
    end

    def toggle
      @style.visible = !@style.visible

      gui_state.request_recalculate
    end

    def show
      already_visible = visible?

      @style.visible = true

      gui_state.request_recalculate unless already_visible
    end

    def hide
      already_hidden = visible?

      @style.visible = true

      gui_state.request_recalculate if already_hidden
    end

    def draw
      return unless visible?
      return unless element_visible?

      @style.render

      render
    end

    def debug_draw
    end

    def update
    end

    def button_down(id)
    end

    def button_up(id)
    end

    def draggable?(button)
      false
    end

    def render
    end

    def hit(x, y)
      x.between?(@style.x, @style.x + width) &&
      y.between?(@style.y, @style.y + height)
    end

    def width
      if visible?
        inner_width + @width
      else
        0
      end
    end

    def content_width
      @width
    end

    def noncontent_width
      (inner_width + outer_width) - width
    end

    def outer_width
      @style.margin_left + width + @style.margin_right
    end

    def inner_width
      (@style.border_thickness_left + @style.padding_left) + (@style.padding_right + @style.border_thickness_right)
    end


    def height
      if visible?
        inner_height + @height
      else
        0
      end
    end

    def content_height
      @height
    end

    def noncontent_height
      (inner_height + outer_height) - height
    end

    def outer_height
      @style.margin_top + height + @style.margin_bottom
    end

    def inner_height
      (@style.border_thickness_top + @style.padding_top) + (@style.padding_bottom + @style.border_thickness_bottom)
    end

    def scroll_width
      @children.sum { |c| c.outer_width }
    end

    def scroll_height
      if is_a?(CyberarmEngine::Element::Flow)
        return 0 if @children.size.zero?

        pairs = [] of Array(Element)
        sorted_children = @children.sort_by { |c| c.style.y }
        array = [] of Element
        y_position = sorted_children.first.style.y

        sorted_children.each do |child|
          unless child.style.y == y_position
            y_position = child.style.y
            pairs << array
            array.clear
          end

          array << child
        end

        pairs << array unless pairs.last == array

        pairs.sum { |pair| pair.map { |pr| pr.outer_height}.max } + @style.padding_bottom + @style.border_thickness_bottom
      else
        @children.sum { |c| c.outer_height } + @style.padding_bottom + @style.border_thickness_bottom
      end
    end

    def max_scroll_width
      scroll_width - outer_width
    end

    def max_scroll_height
      scroll_height - outer_height
    end

    def dimensional_size(size, dimension)
      raise "dimension must be either :width or :height" unless %i[width height].include?(dimension)

      new_size = if size.is_a?(Numeric) && size.between?(0.0, 1.0)
        (@parent.send(:"content_#{dimension}") * size).floor - send(:"noncontent_#{dimension}").floor
      else
        size
      end

      if @parent && @style.fill # Handle fill behavior
        if dimension == :width && @parent.is_a?(Flow)
          return space_available_width - noncontent_width

        elsif dimension == :height && @parent.is_a?(Stack)
          return space_available_height - noncontent_height
        end

      else # Handle min_width/height and max_width/height
        return @style.send(:"min_#{dimension}") if @style.send(:"min_#{dimension}") && new_size < @style.send(:"min_#{dimension}")
        return @style.send(:"max_#{dimension}") if @style.send(:"max_#{dimension}") && new_size > @style.send(:"max_#{dimension}")
      end

      new_size
    end


    def space_available_width
      # TODO: This may get expensive if there are a lot of children, probably should cache it somehow
      fill_siblings = @parent.children.select { |c| c.style.fill }.count.to_f # include self since we're dividing

      available_space = ((@parent.content_width - (@parent.children.reject { |c| c.style.fill }).map(&:outer_width).sum) / fill_siblings)
      (available_space.nan? || available_space.infinite?) ? 0 : available_space.floor # The parent element might not have its dimensions, yet.
    end

    def space_available_height
      # TODO: This may get expensive if there are a lot of children, probably should cache it somehow
      fill_siblings = @parent.children.select { |c| c.style.fill }.count.to_f # include self since we're dividing

      available_space = ((@parent.content_height - (@parent.children.reject { |c| c.style.fill }).map(&:outer_height).sum) / fill_siblings)
      (available_space.nan? || available_space.infinite?) ? 0 : available_space.floor # The parent element might not have its dimensions, yet.
    end

    def root_element?
      @parent.nil?
    end

    def focus(unknown)
      warn "#{self.class}#focus was not overridden!"

      :handled
    end

    def recalculate
      raise "#{self.class}#recalculate was not overridden!"
    end

    def reposition
    end

    def value
      raise "#{self.class}#value was not overridden!"
    end

    def value=(_value)
      raise "#{self.class}#value= was not overridden!"
    end

    def to_s
      "#{self.class} x=#{x} y=#{y} width=#{width} height=#{height} value=#{value.is_a?(String) ? "\"#{value}\"" : value}"
    end

    def inspect
      to_s
    end
  end
end
