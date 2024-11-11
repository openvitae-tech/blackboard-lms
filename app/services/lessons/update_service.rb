class Lessons::UpdateService
  include Singleton

  def update_lesson!(lesson, lesson_params)
    lesson.update!(lesson_params)

    upload_to_vimeo(lesson_params) if Rails.env.production?
  end

  private

  def upload_to_vimeo(lesson_params)
    lesson_params[:local_contents_attributes].each do |_, item|

      next if item[:blob_id].nil?
      UploadVideoToVimeoJob.perform_async(item[:blob_id])
    end
  end
end
