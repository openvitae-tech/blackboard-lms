# frozen_string_literal: true

class AudioTranscriptionService
  include Singleton
  include CommonsHelper

  def transcribe(audio)
    return unless audio.attached?

    audio.open do |file|
      result = Integrations::Llm::Api.llm_instance(provider: :gemini).generate_transcript(file.path)
      return JSON.parse(result.data)['segments'] if result.ok?

      log_error_to_sentry("Audio transcription failed: #{result.data}")
    rescue JSON::ParserError => e
      log_error_to_sentry("JSON parsing error during transcription: #{e.message}")
    end
  end
end
