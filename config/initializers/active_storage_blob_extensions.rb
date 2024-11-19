# frozen_string_literal: true

ActiveSupport.on_load(:active_storage_blob) do
  before_destroy :delete_from_vimeo, if: :s3_video_store?

  private

  def s3_video_store?
    service_name == 's3_video_store'
  end

  def delete_from_vimeo
    blob = ActiveStorage::Blob.find_by!(key:)
    url = blob.metadata[:url]
    DeleteVideoFromVimeoJob.perform_async(url)
  end
end
