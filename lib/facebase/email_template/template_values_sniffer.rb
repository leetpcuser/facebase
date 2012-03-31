# Evaluates a email template sniffing the templates values requested and returns
# them for specification for a real email render
module Facebase
  module EmailTemplate
    class TemplateValuesSniffer

      attr_reader :template_keys

      def initialize
        @template_keys = []
      end

      def template_keys
        @template_keys
      end

      def [](key)
        @template_keys << key
        "sniffed key"
      end

    end
  end
end
