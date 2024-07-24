module Maistro
  module Bedrock
    class Configuration
      attr_accessor :bedrock_client, :model, :inference_config

      def initialize
        @bedrock_client = nil
        @model = 'anthropic.claude-3-5-sonnet-20240620-v1:0'
        @inference_config = {
          max_tokens: 2000,
          temperature: 0
        }
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