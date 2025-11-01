# frozen_string_literal: true

module Lessons
  class PostProcessingService
    include Singleton

    def process_local_contents(local_contents)
      local_contents.each do |content|
        next unless content.video.attached?

        UploadVideoToVimeoJob.perform_async(content.video.blob.id, content.id) if APP_CONFIG.external_video_hosting?
        ExtractAndSaveAudioJob.perform_async(content.id)
      end
    end
  end
end
