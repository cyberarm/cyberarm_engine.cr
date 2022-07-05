module CyberarmEngine
  module DSL
    def flow(options, &block)
      container(CyberarmEngine::Element::Flow, options, &block)
    end

    def stack(options, &block)
      container(CyberarmEngine::Element::Stack, options, &block)
    end

    def container(klass, options, &block)
    end
  end
end
