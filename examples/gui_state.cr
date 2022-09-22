require "./../src/cyberarm_engine"

class Window < CyberarmEngine::Window
  class State < CyberarmEngine::GuiState
    @options : Int32

    def setup
      stack(width: 100, height: 100.0) do
        background 0xff_353535

        title "Hello World"
      end
    end

    def draw
      Gosu.draw_rect(0, 0, window.width, window.height, 0xff_353535)
    end

    def needs_cursor?
      true
    end
  end

  def setup
    push_state(State.new(3))
  end
end

Window.new.show