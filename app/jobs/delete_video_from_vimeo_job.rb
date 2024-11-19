class DeleteVideoFromVimeoJob < BaseJob
  def perform(url)

    return if url.nil?

    service = Vimeo::DeleteVideoService.instance
    service.delete_video(url)
  end
end
