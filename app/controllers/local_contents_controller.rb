# frozen_string_literal: true

class LocalContentsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_course
  before_action :set_course_module
  before_action :set_lesson
  before_action :set_local_content

  def retry
    authorize @local_content

    blob = @local_content.video.blob
    vimeo_url = blob.metadata['url']

    UploadVideoToVimeoJob.perform_async(blob.id, @local_content.id)
    DeleteVideoFromVimeoJob.perform_async(vimeo_url)

    @local_content.update!(updated_at: Time.now)

   redirect_to course_module_lesson_path(@course, @course_module, @lesson, lang: @local_content.lang)
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_course_module
    @course_module = @course.course_modules.find(params[:module_id])
  end

  def set_lesson
    @lesson = @course_module.lessons.find(params[:lesson_id])
  end

  def set_local_content
    if params[:lang].present?
      @local_content = @lesson.local_contents.find_by!(lang: params[:lang])
    else
      @local_content = default_local_content
    end
  end

  def default_local_content
    default_language = @lesson.local_contents.find_by(lang: LocalContent::DEFAULT_LANGUAGE.downcase)
    default_language.present? ? default_language : @lesson.local_contents.first
  end
end
