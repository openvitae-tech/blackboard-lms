# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request spec for Rating', type: :request do
  let(:user) { create :user, :learner }
  let(:admin) { create :user, :admin }

  before do
    sign_in user

    @course = create :course, :published
    @course_module = create :course_module, course: @course
    @lesson = create :lesson, course_module: @course_module
  end

  describe 'GET /lesson/:lesson_id/rating/new' do
    it 'renders the new rating template' do
      get new_course_module_lesson_rating_path(course_id: @course.id,
                                               module_id: @course_module.id,
                                               lesson_id: @lesson.id)

      expect(response.status).to be(200)
      expect(response).to render_template(:new)
    end

    it 'Unauthorized when tags is accessed by admin' do
      sign_in admin

      get new_course_module_lesson_rating_path(course_id: @course.id,
                                               module_id: @course_module.id,
                                               lesson_id: @lesson.id)
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'POST /lesson/:lesson_id/rating' do
    it 'allows rate lesson by learner' do
      expect do
        post course_module_lesson_rating_path(course_id: @course.id,
                                              module_id: @course_module.id,
                                              lesson_id: @lesson.id),
             params: { lesson_rating: { value: 4.0 } }
      end.to change(Event, :count).by(1)
    end

    it 'Does not allow rating lesson by admin' do
      sign_in admin

      expect do
        post course_module_lesson_rating_path(course_id: @course.id,
                                              module_id: @course_module.id,
                                              lesson_id: @lesson.id),
             params: { lesson_rating: { value: 4.0 } }
      end.not_to(change(Event, :count))

      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end
end
