class UploadVideoToVimeoJob < BaseJob
  def perform(id)

    return if id.nil?

    file = ActiveStorage::Blob.find(id)
    UploadVideoToVimeoService.new(file).process
  end
end
