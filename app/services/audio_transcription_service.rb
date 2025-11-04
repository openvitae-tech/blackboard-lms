# frozen_string_literal: true

class AudioTranscriptionService
  include Singleton
  include CommonsHelper

  def transcribe(audio)
    return unless audio.attached?

    audio.open do |file|
      result = Integrations::Llm::Api.llm_instance(provider: :gemini).generate_transcript(file.path)
      return JSON.parse(result.data)['segments'] if result.ok?

      Rails.logger.info("Audio transcription failed: #{result.inspect}")
      log_error_to_sentry("Audio transcription failed: #{result.data}")
    end
  end
end
