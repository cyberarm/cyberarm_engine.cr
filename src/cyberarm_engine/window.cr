module CyberarmEngine
  class Window < Gosu::Window
    @@instance = nil : CyberarmEngine::Window?

    def self.instance
      @@instance
    end

    def self.instance=(klass : CyberarmEngine::Window)
      @@instance = klass
    end

    @last_frame_time : UInt64
    @current_frame_time : UInt64

    def initialize(@width = 800, @height = 600, @fullscreen = false, @update_interval = 1000.0 / 60, @resizable = false, @borderless = false)
      @has_focus = false

      @last_frame_time = Gosu.milliseconds
      @current_frame_time = Gosu.milliseconds

      @states = [] of CyberarmEngine::GameState
      @exit_on_opengl_error = false

      super(@width, @height, @fullscreen, @update_interval, @resizable, @borderless)

      self.caption = "CyberarmEngine.cr v#{CyberarmEngine::VERSION} #{Gosu.language}"
      CyberarmEngine::Window.instance = self

      setup
    end

    def setup
    end

    def draw
      current_state.not_nil!.draw if current_state
    end

    def update
      current_state.not_nil!.update if current_state

      @last_frame_time = Gosu.milliseconds - @current_frame_time
      @current_frame_time = Gosu.milliseconds
    end

    def needs_cursor?
      current_state ? current_state.not_nil!.needs_cursor? : true
    end

    def needs_redraw?
      current_state ? current_state.not_nil!.needs_redraw? : true
    end

    def drop(filename)
      current_state.not_nil!.drop(filename) if current_state
    end

    def gamepad_connected(index)
      current_state.not_nil!.gamepad_connected(index) if current_state
    end

    def gamepad_disconnected(index)
      current_state.not_nil!.gamepad_disconnected(index) if current_state
    end

    def gain_focus
      current_state.not_nil!.gain_focus if current_state
    end

    def lose_focus
      current_state.not_nil!.lose_focus if current_state
    end

    def button_down(id)
      current_state.not_nil!.button_down(id) if current_state
    end

    def button_up(id)
      current_state.not_nil!.button_up(id) if current_state
    end

    def close
      current_state ? current_state.not_nil!.close : super
    end

    def dt
      @last_frame_time / 1000.0
    end

    def aspect_ratio
      width / height.to_f
    end

    def exit_on_opengl_error?
      @exit_on_opengl_error
    end

    def push_state(instance)
      @states << instance

      current_state.not_nil!.setup
      current_state.not_nil!.post_setup
    end

    def current_state : CyberarmEngine::GameState?
      @states.last?
    end

    def pop_state : CyberarmEngine::GameState?
      @states.pop?
    end

    def shift_state : CyberarmEngine::GameState?
      @states.shift?
    end

    def has_focus?
      @has_focus
    end
  end
end
