# frozen_string_literal: true

class ExtractAndSaveAudioJob < BaseJob
  def perform(local_content_id)
    with_tracing "local_content_id=#{local_content_id}" do
      return if local_content_id.nil?

      local_content = LocalContent.find(local_content_id)
      return if local_content.video.blank? || !local_content.video.attached?

      if (blob = ActiveStorage::Blob.find(local_content.video.blob_id))
        blob.open do |file|
          service = FfmpegService.instance
          audio_io = service.extract_audio(file.path)
          filename = "#{File.basename(file.path, '.*')}.mp3"
          local_content.audio.attach(io: audio_io, filename: filename, content_type: 'audio/mpeg')
          local_content.save!
        end
      end
    end
  end
end
