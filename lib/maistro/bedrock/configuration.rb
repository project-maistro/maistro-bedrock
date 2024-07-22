module Maistro
  module Bedrock
    class Configuration
      attr_accessor :bedrock_client

      def initialize
        @bedrock_client = nil
      end

      def configure
        yield(self) if block_given?
      end
    end
  end
end