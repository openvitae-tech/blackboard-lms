# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request spec for Lessons', type: :request do
  let(:user) { create(:user, :admin) }
  let(:learner) { create(:user, :learner) }

  before do
    sign_in user
    @course = create :course, :published
    @course_module_one = create :course_module, course: @course
    @course_module_two = create :course_module, course: @course
    @course.update!(course_modules_in_order: [@course_module_one.id, @course_module_two.id])
  end

  describe 'GET /lessons/:id' do
    before do
      @lesson = create :lesson, course_module: @course_module_one
      @course_module_one.update!(lessons_in_order: [@lesson.id])
    end

    it 'user should able to access lesson' do
      get course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id, id: @lesson.id)

      expect(response.status).to be(200)
      expect(assigns(:lesson)).to eq(@lesson)
      expect(assigns(:course_modules).pluck(:id).sort).to eq(@course.course_modules.pluck(:id).sort)
      expect(response).to render_template(:show)
    end
  end

  describe 'GET /lessons/new' do
    it 'allow access new lesson by admin' do
      get new_course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id)

      expect(response.status).to be(200)
      expect(response).to render_template(:new)
    end

    it 'unauthorized when new lesson is accessed by non-admin' do
      user = learner
      sign_in user

      get new_course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end
  end

  describe 'POST /lessons' do
    before do
      @blob = ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/fixtures/files/sample_video.mp4').open,
        filename: 'sample_video.mp4',
        content_type: 'video/mp4'
      )
    end

    it 'allow creating lessons by admin' do
      expect do
        post course_module_lessons_path(course_id: @course.id, module_id: @course_module_two.id),
             params: lesson_params(@blob)
      end.to change(@course_module_two.lessons, :count).by(1)
    end

    it 'does not allow creating lessons by non-admin' do
      sign_in learner

      expect do
        post course_module_lessons_path(course_id: @course.id, module_id: @course_module_two.id),
             params: lesson_params(@blob)
      end.not_to(change(@course_module_two.lessons, :count))
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end

    it 'create lesson failure' do
      post course_module_lessons_path(course_id: @course.id, module_id: @course_module_two.id),
           params: { lesson: { title: nil } }
      expect(response.status).to eq(422)
    end
  end

  describe 'PUT /lessons/:id/edit' do
    before do
      @lesson = create :lesson, course_module: @course_module_one
    end

    it 'allow access edit lesson by admin' do
      get edit_course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id, id: @lesson.id)

      expect(response.status).to be(200)
      expect(response).to render_template(:edit)
    end


    it 'unauthorized when edit lesson accessed by non-admin' do
      sign_in learner

      get edit_course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id, id: @lesson.id)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end
  end

  describe 'PUT /lessons/:id' do
    before do
      @lesson = create :lesson, course_module: @course_module_two
      @course_module_two.update!(lessons_in_order: [@lesson.id])
      @lesson_title = 'test lesson'
    end

    it 'allow updating lesson by admin' do
      put course_module_lesson_path(course_id: @course.id, module_id: @course_module_two.id, id: @lesson.id),
          params: { lesson: { title: @lesson_title } }
      expect(@lesson.reload.title).to eq(@lesson_title)
    end

    it 'does not allow updating lesson by non-admin' do
      sign_in learner

      put course_module_lesson_path(course_id: @course.id, module_id: @course_module_two.id, id: @lesson.id),
          params: { lesson: { title: @lesson_title } }
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end

    it 'update lesson failure' do
      put course_module_lesson_path(course_id: @course.id, module_id: @course_module_two.id, id: @lesson.id),
          params: { lesson: { title: nil } }

      expect(response.status).to eq(422)
    end
  end

  describe 'DELETE /lessons/:id' do
    before do
      @lesson = create :lesson, course_module: @course_module_one
      @course.update!(is_published: false)
    end

    it 'allow deleting lesson by admin' do
      expect do
        delete course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id, id: @lesson.id)
      end.to change(@course_module_one.lessons, :count).by(-1)
    end

    it 'does not allow deleting lesson by non-admin' do
      sign_in learner

      expect do
        delete course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id, id: @lesson.id)
      end.not_to change(@course_module_one.lessons, :count)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end

    it 'destroy lesson failure' do
      invalid_id = 123
      delete course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id, id: invalid_id)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PUT /lessons/:id/moveup' do
    before do
      @lesson_one, @lesson_two, @lesson_three = create_list(:lesson, 3, course_module: @course_module_two)
      @course_module_two.update!(lessons_in_order: [@lesson_one.id, @lesson_two.id, @lesson_three.id])
    end

    it 'allow changing the lessons order by admin' do
      put moveup_course_module_lesson_path(course_id: @course.id, module_id: @course_module_two.id,
                                           id: @lesson_three.id)
      expect(@course_module_two.reload.lessons_in_order).to eq([@lesson_one.id, @lesson_three.id, @lesson_two.id])
    end

    it 'does not allow changing the lessons order by non-admin' do
      sign_in learner

      put moveup_course_module_lesson_path(course_id: @course.id, module_id: @course_module_two.id,
                                           id: @lesson_three.id)
      expect(@course_module_two.reload.lessons_in_order).to eq([@lesson_one.id, @lesson_two.id, @lesson_three.id])
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end
  end

  describe 'PUT /lessons/:id/movedown' do
    before do
      @lesson_one, @lesson_two, @lesson_three = create_list(:lesson, 3, course_module: @course_module_one)
      @course_module_one.update!(lessons_in_order: [@lesson_one.id, @lesson_two.id, @lesson_three.id])
    end

    it 'allow changing the lessons order by admin' do
      put movedown_course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id,
                                             id: @lesson_one.id)
      expect(@course_module_one.reload.lessons_in_order).to eq([@lesson_two.id, @lesson_one.id, @lesson_three.id])
    end

    it 'does not allow changing the lessons order by non-admin' do
      sign_in learner

      put movedown_course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id,
                                             id: @lesson_one.id)
      expect(@course_module_one.reload.lessons_in_order).to eq([@lesson_one.id, @lesson_two.id, @lesson_three.id])
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end
  end

  describe 'POST /lessons/:id/complete' do
    before do
      @lesson, @lesson_two = create_list :lesson, 2, course_module: @course_module_one
      @course_module_one.update!(lessons_in_order: [@lesson.id, @lesson_two.id])
    end

    it 'learner should able to mark enrolled course lesson as completed' do
      user = learner
      @course.enroll!(user)
      sign_in user

      post complete_course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id, id: @lesson.id)

      expect(user.enrollments.first.completed_lessons).to eq([@lesson.id])
      expect(response).to redirect_to(course_module_lesson_path(course_id: @course, module_id: @course_module_one.id,
                                                                id: @lesson_two))
    end

    it 'does not allow non-learner to mark course lesson as completed' do
      post complete_course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id, id: @lesson.id)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end
  end

  describe 'PUT /lessons/:id/replay' do
    before do
      @lesson = create :lesson, course_module: @course_module_one
      @course_module_one.update!(lessons_in_order: [@lesson.id])
    end

    it 'learner should able to replay the enrolled course lesson' do
      user = learner
      @course.enroll!(user)
      sign_in user

      post complete_course_module_lesson_path(course_id: @course, module_id: @course_module_one.id, id: @lesson)
      expect(user.enrollments.first.completed_lessons).to eq([@lesson.id])

      put replay_course_module_lesson_path(course_id: @course, module_id: @course_module_one.id, id: @lesson)
      expect(user.enrollments.first.completed_lessons).not_to include(@lesson.id)
    end

    it 'does not allow non-learner to replay the lesson' do
      put replay_course_module_lesson_path(course_id: @course, module_id: @course_module_one.id, id: @lesson)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end
  end

  private

  def lesson_params(blob)
    {
      lesson: {
        title: Faker::Lorem.word,
        duration: '30',
        local_contents_attributes: { '1735550839123' => { lang: 'english', blob_id: blob.id } }
      }
    }
  end
end
