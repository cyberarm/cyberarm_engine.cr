require "./../src/cyberarm_engine"

class Window < CyberarmEngine::Window
  class State < CyberarmEngine::GameState
    @options : Int32

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