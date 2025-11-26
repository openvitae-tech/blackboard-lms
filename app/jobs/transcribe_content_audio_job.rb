# frozen_string_literal: true

class TranscribeContentAudioJob < BaseJob
  def perform(local_content_id)
    with_tracing "local_content_id=#{local_content_id}" do
      local_content = LocalContent.find(local_content_id)

      service = AudioTranscriptionService.instance
      result = service.transcribe(local_content.audio)
      raise Errors::LlmTranscriptionError, "Transcription failed: #{result.data}" unless result.ok?

      Transcript.update_with_transaction(local_content, result.data['segments'])
    end
  end
end
