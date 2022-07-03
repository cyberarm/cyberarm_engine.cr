module CyberarmEngine
  module Common
    def window
      CyberarmEngine::Window.instance.not_nil!
    end
  end
end
