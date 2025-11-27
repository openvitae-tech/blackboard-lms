# frozen_string_literal: true

class AudioTranscriptionService
  include Singleton
  include CommonsHelper

  def transcribe(audio)
    raise StandardError, 'Audio file is not attached' if audio.blank?

    audio.open do |file|
      return Integrations::Llm::Api.llm_instance(provider: :gemini).generate_transcript(file.path)
    end
  end
end
