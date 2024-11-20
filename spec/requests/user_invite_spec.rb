# frozen_string_literal: true

RSpec.describe 'Request spec for user invites' do
  describe 'Invite new partner users by Admin' do
    before do
      admin_user = create :user, :admin
      @team = create :team
      sign_in admin_user
    end

    it 'Allows inviting new users' do
      params = {
        user: {
          name: Faker::Name.name,
          email: Faker::Internet.email,
          role: 'learner',
          team_id: @team.id
        }
      }

      expect do
        post '/invites', params:
      end.to change(User, :count).by(1)
    end
  end

  describe 'Invite new partner users by Manager' do
    before do
      @team = create :team
      manager_user = create :user, :manager, team: @team, learning_partner: @team.learning_partner
      sign_in manager_user
    end

    it 'Allows inviting new users by manager' do
      params = {
        user: {
          name: Faker::Name.name,
          email: Faker::Internet.email,
          role: 'learner',
          team_id: @team.id
        }
      }

      expect do
        post '/invites', params:
      end.to change(User, :count).by(1)
    end
  end

  describe 'Bulk invite learners by manager' do
    before do
      @team = create :team
      manager_user = create :user, :manager, team: @team, learning_partner: @team.learning_partner
      sign_in manager_user
    end

    it 'Allow inviting learners in bulk' do
      params = {
        user: {
          bulk_invite: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/valid_bulk_invite.csv')),
          team_id: @team.id
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
          team_id: @team.id
        }
      }

      expect do
        post '/invites', params:
      end.not_to change(User, :count)
    end
  end
end
