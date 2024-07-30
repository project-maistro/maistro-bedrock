module Maistro
  module Bedrock
    class Orchestrator < Maistro::Orchestrator
      def run(prompt)
        configuration.bedrock_client.converse(
          model_id: configuration.model,
          system: [{
            text: system_prompt
          }],
          inference_config: configuration.inference_config,
          messages: [{ role: :user, content: [{ text: prompt }] }]
        )
      end
    end
  end
end
