# frozen_string_literal: true

class ExtractAndSaveAudioJob < BaseJob
  include CommonsHelper

  def perform(local_content_id)
    with_tracing "local_content_id=#{local_content_id}" do
      local_content = LocalContent.find_by(id: local_content_id)
      return if local_content_id.nil? || local_content.video.blank? || !local_content.video.attached?

      blob = local_content.video.blob
      filename = "#{File.basename(blob.filename.to_s, '.*')}.mp3"
      blob.open do |file|
        service = FfmpegService.instance
        audio_io = service.extract_audio(file.path)
        if audio_io.blank?
          log_error_to_sentry("Audio extraction failed for LocalContent ID: #{local_content_id}")
          return
        end
        local_content.audio.attach(io: audio_io, filename: filename, content_type: 'audio/mpeg')
        local_content.save!
      end
    end
  end
end
