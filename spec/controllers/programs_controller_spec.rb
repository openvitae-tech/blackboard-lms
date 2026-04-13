# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProgramsController, type: :controller do
  let(:user) { create(:user, :manager) }
  let(:program) { create(:program, learning_partner: user.learning_partner) }

  before { sign_in user }

  describe '#set_programs_active_nav' do
    context 'when on explore action' do
      it 'sets @active_nav to courses' do
        get :explore
        expect(assigns(:active_nav)).to eq('courses')
      end
    end

    context 'when on show action' do
      it 'sets @active_nav to courses in learner mode' do
        get :show, params: { id: program.id, mode: Program::LEARNER_MODE }
        expect(assigns(:active_nav)).to eq('courses')
      end

      it 'sets @active_nav to programs in manager mode' do
        get :show, params: { id: program.id, mode: Program::MANAGER_MODE }
        expect(assigns(:active_nav)).to eq('programs')
      end

      it 'defaults @active_nav to courses when mode is blank' do
        get :show, params: { id: program.id }
        expect(assigns(:active_nav)).to eq('courses')
      end
    end
  end
end
