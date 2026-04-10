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
    end

    context 'when on programs controller' do
      it 'sets @active_nav to programs' do
        allow(controller).to receive(:controller_name).and_return('programs')
        get :index
        expect(assigns(:active_nav)).to eq('programs')
      end
    end
  end
end
