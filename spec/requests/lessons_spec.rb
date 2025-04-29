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
      @lesson_two = create :lesson, course_module: @course_module_one
      @lesson_three = create :lesson, course_module: @course_module_one
      @lesson_four = create :lesson, course_module: @course_module_two
      @course_module_one.update!(lessons_in_order: [@lesson.id, @lesson_two.id, @lesson_three.id])
      @course_module_two.update!(lessons_in_order: [@lesson_four.id])
    end

    it 'admin should able to access lesson' do
      get course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id, id: @lesson.id)

      expect(response.status).to be(200)
      expect(assigns(:lesson)).to eq(@lesson)
      expect(assigns(:course_modules).pluck(:id).sort).to eq(@course.course_modules.pluck(:id).sort)
      expect(response).to render_template(:show)
    end

    context 'when logged in as learner' do
      before do
        sign_in learner
      end

      it 'returns unauthorized for user if not enrolled to the course' do
        get course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id, id: @lesson.id)
        expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
        expect(response).to redirect_to(error_401_path)
      end

      it 'allows access to a completed lesson' do
        enrollment = @course.enroll!(learner)

        enrollment.update!(completed_lessons: [@lesson.id], current_module_id: @course_module_one.id,
                           current_lesson_id: @lesson.id)

        get course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id, id: @lesson_two.id)
        expect(response.status).to be(200)
      end

      it 'allows access to lessons that come before the last completed lesson after reordering' do
        enrollment = @course.enroll!(learner)

        enrollment.update!(completed_lessons: [@lesson.id], current_module_id: @course_module_one.id,
                           current_lesson_id: @lesson.id)

        get course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id, id: @lesson_three.id)
        expect(response.status).to be(302)
        expect(response).to redirect_to(course_module_lesson_path(course_id: @course.id,
                                                                  module_id: @course_module_one.id, id: @lesson_two.id))

        @course_module_one.update!(lessons_in_order: [@lesson.id, @lesson_three.id, @lesson_two.id])

        get course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id, id: @lesson_three.id)
        expect(response.status).to be(200)
      end

      it 'allows access to lessons that come before the last completed lesson after reordering course module' do
        enrollment = @course.enroll!(learner)

        enrollment.update!(completed_lessons: [@lesson.id, @lesson_two.id], current_module_id: @course_module_one.id,
                           current_lesson_id: @lesson_two.id)

        get course_module_lesson_path(course_id: @course.id, module_id: @course_module_two.id,
                                      id: @lesson_four.id)
        expect(response.status).to be(302)
        expect(response).to redirect_to(course_module_lesson_path(
                                          course_id: @course.id,
                                          module_id: @course_module_one.id, id: @lesson_three.id
                                        ))

        @course.update!(course_modules_in_order: [@course_module_two.id, @course_module_one.id])
        get course_module_lesson_path(course_id: @course.id, module_id: @course_module_two.id,
                                      id: @lesson_four.id)
        expect(response.status).to be(200)
      end

      it 'redirect to the next incomplete lesson when accessing lessons which is not in order' do
        enrollment = @course.enroll!(learner)
        enrollment.update!(completed_lessons: [@lesson.id], current_module_id: @course_module_one.id,
                           current_lesson_id: @lesson.id)

        get course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id, id: @lesson_three.id)
        expect(response.status).to be(302)
        expect(response).to redirect_to(course_module_lesson_path(course_id: @course.id,
                                                                  module_id: @course_module_one.id, id: @lesson_two.id))
      end
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
    it 'allow creating lessons by admin' do
      expect do
        post course_module_lessons_path(course_id: @course.id, module_id: @course_module_two.id),
             params: lesson_params(new_blob)
      end.to change(@course_module_two.lessons, :count).by(1)
    end

    it 'does not allow creating lessons by non-admin' do
      sign_in learner

      expect do
        post course_module_lessons_path(course_id: @course.id, module_id: @course_module_two.id),
             params: lesson_params(new_blob)
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
      expect do
        put course_module_lesson_path(course_id: @course.id, module_id: @course_module_two.id, id: @lesson.id),
            params: { lesson: update_lesson_params(@lesson_title, @lesson, new_blob) }
      end.to change(@lesson.local_contents, :count).by(1)

      @lesson.reload
      local_contents_langs = @lesson.local_contents.pluck(:lang)
      expect(local_contents_langs).to eq(%w[english hindi])
      expect(@lesson.title).to eq(@lesson_title)
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
      sign_in user
      @course.enroll!(user)

      post complete_course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id, id: @lesson.id)

      expect(user.enrollments.first.completed_lessons).to eq([@lesson.id])
      expect(response).to redirect_to(course_module_lesson_path(course_id: @course, module_id: @course_module_one.id,
                                                                id: @lesson_two))
    end

    it 'Redirect to course module page upon completing the last lesson' do
      sign_in learner
      @course.enroll!(learner)

      enrollment = learner.get_enrollment_for(@course)
      enrollment.update!(completed_lessons: [@lesson.id], current_module_id: @course_module_one.id,
                         current_lesson_id: @lesson.id)

      post complete_course_module_lesson_path(course_id: @course.id,
                                              module_id: @course_module_one.id, id: @lesson_two.id)
      expect(response.status).to eq(302)
      expect(response).to redirect_to(course_path(@course.id))
    end

    it 'does not allow non-learner to mark course lesson as completed' do
      post complete_course_module_lesson_path(course_id: @course.id, module_id: @course_module_one.id, id: @lesson.id)
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

  def update_lesson_params(updated_lesson_title, lesson, blob)
    {
      title: updated_lesson_title,
      local_contents_attributes: {
        '0' => {
          id: lesson.local_contents.first.id,
          _destroy: false
        },
        '1' => {
          lang: 'hindi',
          _destroy: false,
          blob_id: blob.id
        }
      }
    }
  end

  def new_blob
    ActiveStorage::Blob.create_and_upload!(
      io: Rails.root.join('spec/fixtures/files/sample_video.mp4').open,
      filename: 'sample_video.mp4',
      content_type: 'video/mp4'
    )
  end
end
