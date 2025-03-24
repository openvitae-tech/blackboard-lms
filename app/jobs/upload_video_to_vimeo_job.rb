# frozen_string_literal: true

class UploadVideoToVimeoJob < BaseJob
  def perform(id, local_content_id)
    with_tracing "blob_id=#{id}" do
      return if id.nil?

      file = ActiveStorage::Blob.find(id)
      service = Vimeo::UploadVideoService.instance
      service.upload_video(file, local_content_id)
    end
  end
end
