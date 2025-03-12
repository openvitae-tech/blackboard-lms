# frozen_string_literal: true

RSpec.describe 'Request spec for user invites' do
  let(:team) { create(:team) }

  describe 'GET /invites/new' do
    before do
      support_user = create :user, role: 'support', team:, learning_partner: team.learning_partner
      sign_in support_user
    end

    it 'Allow access new course module by support user' do
      get new_invite_path(team_id: team.id)

      expect(response.status).to be(200)
      expect(response).to render_template(:new)
      expect(assigns(:team)).to eq(team)
    end

    it 'Returns unauthorized' do
      learner = create :user, :learner, team:, learning_partner: team.learning_partner
      sign_in learner

      get new_invite_path(team_id: team.id)
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end
  end

  describe 'Invite new partner users by Admin' do
    before do
      admin_user = create :user, :admin
      sign_in admin_user
    end

    it 'Allows inviting new users' do
      params = {
        user: {
          name: Faker::Name.name,
          email: Faker::Internet.email,
          role: 'learner',
          team_id: team.id
        }
      }

      expect do
        post '/invites', params:
      end.to change(User, :count).by(1)
    end
  end

  describe 'Invite new partner users by Manager' do
    before do
      manager_user = create :user, :manager, team:, learning_partner: team.learning_partner
      sign_in manager_user
    end

    it 'Allows inviting new users by manager' do
      params = {
        user: {
          name: Faker::Name.name,
          email: Faker::Internet.email,
          role: 'learner',
          team_id: team.id
        }
      }

      expect do
        post '/invites', params:
      end.to change(User, :count).by(1)
    end
  end

  describe 'POST /invites' do
    before do
      support_user = create :user, role: 'support', team:, learning_partner: team.learning_partner
      sign_in support_user
    end

    it 'Allow inviting new users by support user' do
      params = {
        user: {
          name: Faker::Name.name,
          email: Faker::Internet.email,
          role: 'learner',
          team_id: team.id
        }
      }

      expect do
        post invites_path, params:
      end.to change(User, :count).by(1)
    end
  end

  describe 'Bulk invite learners by manager' do
    before do
      manager_user = create :user, :manager, team:, learning_partner: team.learning_partner
      sign_in manager_user
    end

    it 'Allow inviting learners in bulk' do
      params = {
        user: {
          bulk_invite: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/valid_bulk_invite.csv')),
          team_id: team.id
        }
      }

      expect do
        post '/invites', params:
      end.to change(User, :count).by(3)
    end

    it 'Does not creates invitation for invalid rows in the csv' do
      params = {
        user: {
          bulk_invite: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/invalid_bulk_invite.csv')),
          team_id: team.id
        }
      }

      expect do
        post '/invites', params:
      end.not_to change(User, :count)
    end
  end
end
