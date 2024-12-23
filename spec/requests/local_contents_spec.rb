# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request spec for LocalContents', type: :request do
  let(:user) { create(:user, :admin) }

  before do
    sign_in user

    @course = create :course, :published
    @course_module = create :course_module, course: @course
    @lesson = create :lesson, course_module: @course_module
  end

  describe 'GET /local_contents/:id/retry' do
    it 'Allow retry upload video to vimeo by admin' do
      Sidekiq::Testing.fake! do
        put retry_course_module_lesson_local_content_path(
          course_id: @course.id,
          module_id: @course_module.id,
          lesson_id: @lesson.id,
          lang: 'english'
        )

        expect(UploadVideoToVimeoJob.jobs.size).to be(1)
        expect(DeleteVideoFromVimeoJob.jobs.size).to be(1)
        expect(response).to redirect_to(course_module_lesson_path(@course, @course_module, @lesson,
                                                                  lang: 'english'))
      end
    end

    it 'Unauthorized when retry is accessed by non-admin' do
      user.update(role: :learner)

      put retry_course_module_lesson_local_content_path(
        course_id: @course.id,
        module_id: @course_module.id,
        lesson_id: @lesson.id,
        lang: 'english'
      )

      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end
end
