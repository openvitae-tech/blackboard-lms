# frozen_string_literal: true

class TranscribeContentAudioJob < BaseJob
  def perform(local_content_id)
    with_tracing "local_content_id=#{local_content_id}" do
      local_content = LocalContent.find(local_content_id)

      service = AudioTranscriptionService.instance
      transcripts_data = service.transcribe(local_content.audio)
      Transcript.update_with_transaction(local_content, transcripts_data) if transcripts_data.present?
    end
  end
end
