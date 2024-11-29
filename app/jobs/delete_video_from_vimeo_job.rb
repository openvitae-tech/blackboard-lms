class DeleteVideoFromVimeoJob < BaseJob
  def perform(url)
    with_tracing "url=#{url}" do
      return if url.nil?

      service = Vimeo::DeleteVideoService.instance
      service.delete_video(url)
    end
  end
end
