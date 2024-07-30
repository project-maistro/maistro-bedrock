module Maistro
  module Bedrock
    class Orchestrator < Maistro::Orchestrator
      def run(prompt)
        agent_name = configuration.bedrock_client.converse(
          model_id: configuration.model,
          system: [{
            text: system_prompt
          }],
          inference_config: configuration.inference_config,
          messages: [{ role: :user, content: [{ text: prompt }] }]
        ).output.message.content.first.text
        agent_by_name[agent_name]
      end

      def configuration
        Maistro::Bedrock::Configuration.configuration
      end
    end
  end
end
