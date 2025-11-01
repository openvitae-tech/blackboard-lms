# frozen_string_literal: true

class ExtractAndSaveAudioJob < BaseJob
  include CommonsHelper

  def perform(local_content_id)
    with_tracing "local_content_id=#{local_content_id}" do
      local_content = LocalContent.find_by(id: local_content_id)
      return if local_content.nil? || local_content.video.blank? || !local_content.video.attached?

      local_content.video.blob.open do |file|
        service = FfmpegService.instance
        audio_io = service.extract_audio(file.path)
        if audio_io.blank?
          log_error_to_sentry("Audio extraction failed for LocalContent ID: #{local_content_id}")
          return
        end

        filename = "#{SecureRandom.uuid}.mp3"
        local_content.audio.attach(
          io: audio_io,
          filename: filename,
          content_type: 'audio/mpeg',
          key: "audio/#{filename}"
        )
        local_content.save!
      end
    end
  end
end
