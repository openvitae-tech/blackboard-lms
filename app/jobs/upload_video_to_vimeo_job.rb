class UploadVideoToVimeoJob < BaseJob
  def perform(id)

    return if id.nil?

    file = ActiveStorage::Blob.find(id)
    service = Vimeo::UploadVideoService.instance
    service.upload_video(file)
  end
end
