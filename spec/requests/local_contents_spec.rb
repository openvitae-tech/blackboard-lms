# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request spec for LocalContents', type: :request do
  let(:admin) { create(:user, :admin) }

  before do
    sign_in admin

    @course = create :course, :published
    @course_module = create :course_module, course: @course
    @lesson = create :lesson, course_module: @course_module
    @local_content = @lesson.local_contents.first
  end

  describe 'GET /local_contents/:id/retry' do
    it 'Allow retry upload video to vimeo by admin' do
      Sidekiq::Testing.fake! do
        travel_to Time.zone.today + 1.month

        put retry_local_content_path(@local_content)
        @local_content.reload

        expect(UploadVideoToVimeoJob.jobs.size).to be(1)
        expect(DeleteVideoFromVimeoJob.jobs.size).to be(1)
        expect(@local_content.video_published_at).to be_within(1.second).of(Time.zone.now)
      end
    end

    it 'Unauthorized when retry is accessed by non-admin' do
      user = create(:user, :learner)
      sign_in user

      put retry_local_content_path(@local_content)

      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end
end
