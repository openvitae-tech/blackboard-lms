# frozen_string_literal: true

RSpec.describe 'Request spec for Programs' do
  let(:learning_partner) { create :learning_partner }
  let(:learner) { create :user, :learner, learning_partner: }
  let(:user) { create :user, :manager, learning_partner: }

  let(:course) { create :course }
  let!(:program) { create :program, courses: [course], users: [learner], learning_partner: }

  before do
    sign_in user
  end

  describe 'GET /programs' do
    before do
      @new_program = create(:program, courses: [course], users: [learner], learning_partner: learning_partner)
    end

    it 'allows listing programs for privileged user' do
      get programs_path

      expect(response.status).to be(200)
      expect(assigns(:programs).pluck(:id).sort).to eq([program.id, @new_program.id].sort)
    end

    it 'unauthorized for non-privileged user' do
      sign_in learner

      get programs_path
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'GET /programs/new' do
    it 'renders new template for privileged user' do
      get new_program_path

      expect(response.status).to be(200)
      expect(response).to render_template(:new)
    end

    it 'unauthorized for non-privileged user' do
      sign_in learner

      get new_program_path
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'POST /programs' do
    it 'creates a new program' do
      expect do
        post programs_path, params: { program: { name: 'My Program' } }
      end.to change(learning_partner.programs, :count).by(1)
      expect(flash[:success]).to eq(I18n.t('resource.created', resource_name: 'Program'))
    end

    it 'unauthorized for non-privileged user' do
      sign_in learner

      post programs_path, params: { program: { name: 'My Program' } }
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end

    it 'renders new template when validation fails' do
      post programs_path, params: { program: { name: '' } }
      expect(response.status).to eq(422)
      expect(response).to render_template(:new)
    end
  end

  describe 'GET /programs/:id' do
    it 'shows program details' do
      get program_path(program)

      expect(response.status).to be(200)
      expect(assigns(:courses).pluck(:id)).to eq([course.id])
    end

    it 'allows non-privileged user to view program details' do
      sign_in learner

      get program_path(program)
      expect(response.status).to be(200)
    end
  end

  describe 'GET /programs/:id/edit' do
    it 'renders edit page' do
      get edit_program_path(program)

      expect(response.status).to be(200)
      expect(response).to render_template(:edit)
    end

    it 'unauthorized for non-privileged user' do
      sign_in learner

      get edit_program_path(program)
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'PATCH /programs/:id' do
    it 'updates a program' do
      patch program_path(program), params: {
        program: { name: 'Updated Name' }
      }
      expect(program.reload.name).to eq('Updated Name')
      expect(flash[:success]).to eq(I18n.t('resource.updated', resource_name: 'Program'))
    end
  end

  describe 'PATCH /programs/:id/add_courses' do
    it 'renders add courses page' do
      get add_courses_program_path(program)

      expect(response.status).to be(200)
      expect(response).to render_template(:add_courses)
    end

    it 'unauthorized for non-privileged user' do
      sign_in learner

      get add_courses_program_path(program)
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'PATCH /programs/:id/create_courses' do
    before do
      @new_course = create :course
    end

    it 'add courses to program' do
      post create_courses_program_path(program), params: { course_ids: [@new_course.id] }

      program.reload
      expect(program.courses.pluck(:id)).to eq([course.id, @new_course.id].sort)
    end

    it 'unauthorized for non-privileged user' do
      sign_in learner

      post create_courses_program_path(program), params: { course_ids: [@new_course.id] }
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'DELETE /programs/:id' do
    it 'deletes a program' do
      expect do
        delete program_path(program)
      end.to change(Program, :count).by(-1)
      expect(flash[:success]).to eq(I18n.t('resource.deleted', resource_name: 'Program'))
    end

    it 'unauthorized for non-privileged user' do
      sign_in learner

      delete program_path(program)
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'DELETE /programs/:id/confirm_destroy' do
    it 'renders confirmation view of delete program' do
      get confirm_destroy_program_path(program)

      expect(response.status).to be(200)
      expect(response).to render_template(:confirm_destroy)
    end

    it 'unauthorized for non-privileged user' do
      sign_in learner

      get confirm_destroy_program_path(program)
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'DELETE /programs/:id/bulk_destroy_courses' do
    before do
      @course2 = create(:course)
      program.update(courses: [course, @course2])
    end

    it 'deletes selected courses from a program' do
      expect do
        delete bulk_destroy_courses_program_path(program), params: { course_ids: [@course2.id] }
      end.to change(program.program_courses, :count).by(-1)
      expect(flash[:success]).to eq(I18n.t('resource.deleted', resource_name: 'Courses'))
    end

    it 'unauthorized for non-privileged user' do
      sign_in learner

      delete bulk_destroy_courses_program_path(program), params: { course_ids: [@course2.id] }
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'GET /programs/:id/confirm_bulk_destroy_courses' do
    before do
      @course2 = create(:course)
      program.update(courses: [course, @course2])
    end

    it 'renders confirmation view for bulk destroy' do
      get confirm_bulk_destroy_courses_program_path(program), params: { course_ids: [@course2.id] }
      expect(response.status).to be(200)
      expect(response).to render_template(:confirm_bulk_destroy_courses)
    end

    it 'unauthorized for non-privileged user' do
      sign_in learner

      get confirm_bulk_destroy_courses_program_path(program), params: { course_ids: [@course2.id] }
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end
end
