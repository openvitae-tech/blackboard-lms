# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'ok'
    end
  end

  let(:user) { create(:user, :learner) }

  before { sign_in user }

  describe '#set_active_nav' do
    context 'when params[:active_nav] is present' do
      it 'uses params[:active_nav] regardless of controller' do
        allow(controller).to receive(:controller_name).and_return('lessons')
        get :index, params: { active_nav: 'programs' }
        expect(assigns(:active_nav)).to eq('programs')
      end
    end

    context 'when on a top-level controller' do
      it 'sets @active_nav to dashboards' do
        allow(controller).to receive(:controller_name).and_return('dashboards')
        get :index
        expect(assigns(:active_nav)).to eq('dashboards')
      end

      it 'sets @active_nav to teams' do
        allow(controller).to receive(:controller_name).and_return('teams')
        get :index
        expect(assigns(:active_nav)).to eq('teams')
      end

      it 'sets @active_nav to my_profiles' do
        allow(controller).to receive(:controller_name).and_return('my_profiles')
        get :index
        expect(assigns(:active_nav)).to eq('my_profiles')
      end

      it 'sets @active_nav to supports' do
        allow(controller).to receive(:controller_name).and_return('supports')
        get :index
        expect(assigns(:active_nav)).to eq('supports')
      end

      it 'sets @active_nav to settings for settings controller' do
        allow(controller).to receive(:controller_name).and_return('settings')
        get :index
        expect(assigns(:active_nav)).to eq('settings')
      end

      it 'sets @active_nav to settings for tags controller' do
        allow(controller).to receive(:controller_name).and_return('tags')
        get :index
        expect(assigns(:active_nav)).to eq('settings')
      end
    end

    context 'when on a courses-related inner page' do
      it 'sets @active_nav to courses for lessons controller' do
        allow(controller).to receive(:controller_name).and_return('lessons')
        get :index
        expect(assigns(:active_nav)).to eq('courses')
      end

      it 'sets @active_nav to courses for course_modules controller' do
        allow(controller).to receive(:controller_name).and_return('course_modules')
        get :index
        expect(assigns(:active_nav)).to eq('courses')
      end

      it 'sets @active_nav to courses for quizzes controller' do
        allow(controller).to receive(:controller_name).and_return('quizzes')
        get :index
        expect(assigns(:active_nav)).to eq('courses')
      end

      it 'falls back to courses for unknown inner page controllers' do
        allow(controller).to receive(:controller_name).and_return('unknown_inner')
        get :index
        expect(assigns(:active_nav)).to eq('courses')
      end
    end

    context 'when on programs controller' do
      before { allow(controller).to receive(:controller_name).and_return('programs') }

      it 'sets @active_nav to my_courses when mode is learner' do
        allow(controller).to receive(:action_name).and_return('show')
        get :index, params: { mode: Program::LEARNER_MODE }
        expect(assigns(:active_nav)).to eq('my_courses')
      end

      it 'sets @active_nav to my_courses when mode is blank' do
        allow(controller).to receive(:action_name).and_return('show')
        get :index
        expect(assigns(:active_nav)).to eq('my_courses')
      end

      it 'sets @active_nav to programs when mode is manager' do
        allow(controller).to receive(:action_name).and_return('show')
        get :index, params: { mode: Program::MANAGER_MODE }
        expect(assigns(:active_nav)).to eq('programs')
      end

      it 'sets @active_nav to programs for index action' do
        allow(controller).to receive(:action_name).and_return('index')
        get :index
        expect(assigns(:active_nav)).to eq('programs')
      end

      it 'sets @active_nav to courses for explore action' do
        allow(controller).to receive(:action_name).and_return('explore')
        get :index
        expect(assigns(:active_nav)).to eq('courses')
      end
    end
  end
end
