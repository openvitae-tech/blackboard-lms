# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoursesController, type: :controller do
  let(:user) { create(:user, :admin) }
  let(:course) { create(:course, :published) }

  before { sign_in user }

  describe '#set_course_active_nav' do
    context 'when mode is manager' do
      it 'sets @active_nav to programs' do
        get :show, params: { id: course.id, mode: Program::MANAGER_MODE }
        expect(assigns(:active_nav)).to eq('programs')
      end
    end

    context 'when mode is learner' do
      it 'sets @active_nav to courses' do
        get :show, params: { id: course.id, mode: Program::LEARNER_MODE }
        expect(assigns(:active_nav)).to eq('courses')
      end
    end

    context 'when mode is not present' do
      it 'defaults @active_nav to courses' do
        get :show, params: { id: course.id }
        expect(assigns(:active_nav)).to eq('courses')
      end
    end
  end
end
