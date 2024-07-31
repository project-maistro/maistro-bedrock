module Maistro
  module Bedrock
    class Agent < Maistro::Agent::Base

      def interact(prompt)
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

      def configuration
        Maistro::Bedrock::Configuration.configuration
      end

      def _client
        configuration.bedrock_client
      end

      def tool_config
        return {} unless functions.any?

        {
          tool_config: {
            tools: _tool_list
          }
        }
      end

      def converse_options
        {
          model_id: configuration.model,
          system: [{
            text: system_prompt
          }],
          inference_config: configuration.inference_config,
          messages: thread
        }.merge(tool_config)
      end

      def _converse
        response = _client.converse(converse_options)
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
    end
  end
end
