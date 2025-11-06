# frozen_string_literal: true

class AudioTranscriptionService
  include Singleton
  include CommonsHelper

  def transcribe(audio)
    raise StandardError, 'Audio file is not attached' if audio.blank?

    audio.open do |file|
      result = Integrations::Llm::Api.llm_instance(provider: :gemini).generate_transcript(file.path)
      return result.data['segments'] if result.ok?

      log_error_to_sentry("Audio transcription failed: #{result.data}")
    end
  end
end
