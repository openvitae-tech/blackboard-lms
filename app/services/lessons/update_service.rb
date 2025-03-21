# frozen_string_literal: true

module Lessons
  class UpdateService
    include Singleton

    def update_lesson!(lesson, lesson_params)
      lesson.update!(lesson_params)
      upload_to_vimeo(lesson_params) if Rails.env.production?
    end

    private

    def upload_to_vimeo(lesson_params)
      lesson_params[:local_contents_attributes].each_value do |item|
        next if item[:blob_id].nil?

        local_content = ActiveStorage::Attachment.find_by!(blob_id: item[:blob_id]).record
        UploadVideoToVimeoJob.perform_async(item[:blob_id], local_content.id)
      end
    end
  end
end
