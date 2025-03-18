# frozen_string_literal: true

class LocalContentsController < ApplicationController
  include LessonsHelper

  before_action :set_local_content

  def retry
    authorize @local_content

    @lesson = @local_content.lesson
    @course_module = @lesson.course_module
    @course = @course_module.course

    blob = @local_content.video.blob
    vimeo_url = blob.metadata['url']

    @local_content.update!(status: :pending, video_published_at: Time.zone.now)
    @video_iframe = get_video_iframe(@local_content)

    # Here we want to delete any previous video instance at Vimeo we do that only after uploading and setting a new
    # video otherwise any existing instance will be unavailable till the new video is read at vimeo.
    UploadVideoToVimeoJob.perform_async(blob.id, @local_content.id)
    DeleteVideoFromVimeoJob.perform_async(vimeo_url)
  end

  private

  def set_local_content
    @local_content = LocalContent.find(params[:id])
  end
end
