# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourseModulesController, type: :request do
  let(:user) { create(:user, :admin) }

  before do
    sign_in user
    @course = course_with_associations
    @course_module = @course.course_modules.first
  end

  describe 'GET /course_modules/:id' do
    it 'Allow access course module by admin' do
      get course_module_path(@course.id, @course_module.id)
      expect(response.status).to be(200)
      expect(response).to render_template(:show)
    end

    it 'Unauthorized when course module accessed by non-admin' do
      user.update(role: :learner)

      get course_module_path(@course.id, @course_module.id)
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'GET /course_modules/new' do
    it 'Allow access new course module by admin' do
      get new_course_module_path(@course.id)

      expect(response.status).to be(200)
      expect(response).to render_template(:new)
    end

    it 'Unauthorized when new course module is accessed by non-admin' do
      user.update(role: :learner)

      get new_course_module_path(@course.id)
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'GET /course_modules/:id/edit' do
    it 'Allow access edit course module by admin' do
      get edit_course_module_path(@course.id, @course_module.id)

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:edit)
    end

    it 'Unauthorized when edit course module accessed by non-admin' do
      user.update(role: :learner)

      get edit_course_module_path(@course.id, @course_module.id)

      expect(response).to have_http_status(:found)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'POST /course_modules' do
    it 'Allow creating a new course module by admin' do
      expect do
        post course_modules_path(@course.id), params: course_module_params
      end.to change(@course.course_modules, :count).by(1)

      expect(response).to redirect_to(course_path(@course))
    end

    it 'Does not allow creating course module by non-admin' do
      user.update(role: :learner)

      expect do
        post course_modules_path(@course.id), params: course_module_params
      end.not_to(change(@course.course_modules, :count))
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end

    it 'Does not allow creating course module for invalid course' do
      invalid_id = 123
      post course_modules_path(invalid_id), params: course_module_params

      expect(response).to have_http_status(:not_found)
    end

    it 'create course module failure' do
      post course_modules_path(@course.id), params: { course_module: { title: nil } }

      expect(response.status).to eq(422)
    end
  end

  describe 'PUT /course_modules/:id' do
    it 'Allow updating course module by admin' do
      put course_module_path(@course.id, @course_module.id), params: course_module_params

      expect(@course_module.reload.title).to eq(course_module_params[:course_module][:title])
      expect(response).to redirect_to(course_module_path(@course, @course_module))
    end

    it 'Does not allow updating course module by non-admin' do
      user.update(role: :learner)

      put course_module_path(@course.id, @course_module.id), params: course_module_params
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end

    it 'Update course module failure' do
      put course_module_path(@course.id, @course_module.id), params: { course_module: { title: nil } }

      expect(response.status).to eq(422)
    end
  end

  describe 'DELETE /course_modules/:id' do
    it 'Allow deleting course module by admin' do
      expect do
        delete course_module_path(@course.id, @course_module.id)
      end.to change(@course.course_modules, :count).by(-1)
      expect(response).to redirect_to(course_path(@course))
    end

    it 'Does not allow deleting course module by non-admin' do
      user.update(role: :learner)

      expect do
        delete course_module_path(@course.id, @course_module.id)
      end.not_to change(@course.course_modules, :count)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end

    it 'Destroy course module failure' do
      invalid_id = 123
      delete course_module_path(@course.id, invalid_id)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PUT /course_modules/:id/moveup' do
    before do
      @module_one = create :course_module, course: @course
      @module_two = create :course_module, course: @course

      new_ids = @course.course_modules_in_order + [@module_one.id, @module_two.id]
      @course.update!(course_modules_in_order: new_ids)
    end

    it 'Allow changing the order of course module by admin' do
      put moveup_course_module_path(@course.id, @module_one.id)

      expect(@course.reload.course_modules_in_order).to eq([@module_one.id, @course_module.id, @module_two.id])
      expect(response).to redirect_to(course_path(@course))
    end

    it 'Does not allow changing the order of course module by non-admin' do
      user.update(role: :learner)

      put moveup_course_module_path(@course.id, @module_one.id)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'PUT /course_modules/:id/movedown' do
    before do
      @module_one = create :course_module, course: @course
      @module_two = create :course_module, course: @course

      new_ids = @course.course_modules_in_order + [@module_one.id, @module_two.id]
      @course.update!(course_modules_in_order: new_ids)
    end

    it 'Allow changing the order of course module by admin' do
      put movedown_course_module_path(@course.id, @module_one.id)

      expect(@course.reload.course_modules_in_order).to eq([@course_module.id, @module_two.id, @module_one.id])
      expect(response).to redirect_to(course_path(@course))
    end

    it 'Does not allow changing the order of course module by non-admin' do
      user.update(role: :learner)

      put movedown_course_module_path(@course.id, @module_one.id)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  private

  def course_module_params
    {
      course_module: {
        title: 'test module'
      }
    }
  end
end
