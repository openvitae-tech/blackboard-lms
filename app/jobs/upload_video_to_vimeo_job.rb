class UploadVideoToVimeoJob < BaseJob
  def perform(id)
    with_tracing "blob_id=#{id}" do
      return if id.nil?
      file = ActiveStorage::Blob.find(id)
      service = Vimeo::UploadVideoService.instance
      service.upload_video(file)
    end
  end
end
