module CyberarmEngine
  class GameState
    include Common

    property :options, :global_pause
    getter :game_objects

    @down_keys : Hash(UInt32, Bool)

    def initialize(@options)
      @game_objects = [] of GameObject
      @global_pause = false
      @down_keys = {} of UInt32 => Bool
    end

    def setup
    end

    def post_setup
    end

    def draw
      @game_objects.each do |o|
        o.draw
      end
    end

    def update
      @game_objects.each do |o|
        o.update
      end
    end

    def needs_cursor?
      true
    end

    def needs_redraw?
      true
    end

    def drop(filename)
    end

    def gamepad_connected(index)
    end

    def gamepad_disconnected(index)
    end

    def gain_focus
    end

    def lose_focus
    end

    def button_down(id)
      @down_keys[id] = true

      @game_objects.each do |o|
        o.button_down(id)
      end
    end

    def button_up(id)
      @down_keys.delete(id)

      @game_objects.each do |o|
        o.button_up(id)
      end
    end

    def close : Bool
      CyberarmEngine::Window.instance.not_nil!.close!
    end

    def destroy
      @game_objects.each(&:destroy)
      @game_objects.clear
    end
  end
end
