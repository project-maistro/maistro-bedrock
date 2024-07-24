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

      class << self
        attr_writer :configuration

        def configuration
          @configuration ||= Configuration.new
        end

        def configure
          yield(configuration) if block_given?
        end

        def reset_configuration!
          @configuration = Configuration.new
        end
      end
    end
  end
end