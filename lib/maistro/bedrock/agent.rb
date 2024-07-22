module Maistro
  module Agent
    class Agent < Maistro::Agent::Base

      attr_accessor :thread

      def initialize(name:)
        @thread = []
        super
      end

      def start_interaction(prompt)
        thread << {
          role: :user,
          content: [
            text: prompt
          ]
        }
        _converse
      end

      private

      def _function_by_name
        @function_by_name ||= functions.each_with_object({}) do |function, hash|
          hash[function.new.name] = function
        end
      end

      def _tool_list
        functions.map do |function|
          definition = function.new
          {
            tool_spec: {
              name: definition.name,
              description: definition.description
            }.merge(definition.parameters)
          }
        end
      end

      def _converse
        response = _client.converse(
          model_id: "anthropic.claude-3-5-sonnet-20240620-v1:0",
          system: [{
            text: prompt
          }],
          inference_config: {
            max_tokens: 2000,
            temperature: 0
          },
          tool_config: {
            tools: _tool_list
          },
          messages: thread
        )
        thread << response.output.message
        return response.output.message[:content].first[:text] if response.stop_reason != "tool_use"

        thread << _run_tool(response)
        _converse
      end

      def _run_tool(response)
        message = { role: :user, content: [] }
        response.output.message.content.each do |content|
          next unless content.tool_use

          message[:content] << {
            tool_result: {
              tool_use_id: content.tool_use.tool_use_id,
              content: [{
                json: {
                  result: _function_by_name[content.tool_use[:name]].new.run
                }
              }]
            }
          }
        end
        message
      end

      def _client
        @_client ||= Aws::BedrockRuntime::Client.new(
          region: "us-east-1",
          endpoint: "https://bedrock-runtime.us-east-1.amazonaws.com",
          credentials: Aws::Credentials.new("ASIATAWWSTMDLAI3BA5T", "XdPW/6tXfi8QhjnA00o8bcYg666L/qHCrMv02LWF",
                                            "IQoJb3JpZ2luX2VjEFoaCXVzLWVhc3QtMSJIMEYCIQDQ0jnmQbC6D9/Lp08UTLT4PU+ycg4xUeAr4JtoXIRZAwIhAP0Sk7JUPFfarDy1D6XF/+8zIuE4SkKCguhn83ufsuHeKpgDCDMQAxoMMjA3NjgyMTgxODk0IgxAKAlA7fIq3FpCg/cq9QLw0WhhaCLKAK0Rqj1omutlkzNgM20LhKsIGM2q9BR2JPReyCN6aeMhp/ENK5LkmlNnsCr2UdIqa1Jy/PbvP2zWtJdJg8g06uzRn89/9vqzL2YF4Qy3hlu9buzgOHma/8dgzULnAAWCrssNAcWDVQkZ4W1bC2zkMYc0bikcHcUM5wzycaUVJ1/dq5OQwJmq9gCpbEW4SGUGbiaQXVRQ4uKkgXaYgC6z9O75RJYHZO8SXddg8NeHntiNrbTSiweIMTc8iKREdMw9hz5mKkkDqNecbCIZmbdR6IrMdfK+vHzq95uZy0tBWSXNGD5VNSvvLPqI4eNDOR/l7yhjkoCTDiQGGUAAE5QaS4LcqQIPXYV0wGUKTCRhZ0pksmY7D3eiXVTDdGXFaRL/L7pqi4UhSDDDbAd0wKzlW1xxvkH7kKJUXhx5XfIVDhQh7RIRgEhUAVzdKp6DmzlpNI7jMC7L40s5Yje748lwhOpE2GR/KlKTP7ejWmNdMM3R6rQGOqUBz08AXOUhtW+fQjDSVwWD02AiuDEaO/Bkqj81u2PWeVbfnlhCosFrvLTJlOG1xPIw5PbM9n8ZmskHEcJZ8dCLaAhZyN1uqrS8p9xN3VPHHtchUeKwi+Ya+83uqJdvNJL422JiloB+wdCgUz2H78akN2fjKB71lsFrjaXSO2HKNpM4VOEBqW+mv0W0avJpBRV7Xn5FlSh9pPqifXHPhusuAC5FP7eD")
        )
      end
    end
  end
end
