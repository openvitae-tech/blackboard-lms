# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delete users', type: :request do
  before do
    @team = create(:team)
    @admin = create :user, :admin
    @manager = create :user, :manager, team: @team, learning_partner: @team.learning_partner
    @learner = create :user, :learner,
                      team: @team,
                      learning_partner: @team.learning_partner,
                      state: UserState::UNVERIFIED
    @learner_verified = create :user, :learner,
                               team: @team,
                               learning_partner: @team.learning_partner,
                               state: UserState::VERIFIED
  end

  describe 'as admin user' do
    before do
      sign_in @admin
    end

    it 'not allowed to delete the user' do
      expect do
        delete member_path(@learner_verified)
      end.not_to change(User, :count)
    end

    it 'redirect to error path' do
      delete member_path(@learner_verified)
      expect(response).to redirect_to(error_401_path)
    end
  end

  describe 'ad manager' do
    before do
      sign_in @manager
    end

    it 'allow deleting unverified users' do
      expect do
        delete member_path(@learner)
      end.to change(User, :count).by(-1)
    end

    it 'allow deleting verified users' do
      expect do
        delete member_path(@learner_verified)
      end.to change(User, :count).by(-1)
    end

    it "redirect the manager to user's team page" do
      delete member_path(@learner)
      expect(response).to redirect_to(team_path(@team))
    end

    it 'deletes any of the team enrolled courses' do
      course = create :course, :published
      CourseManagementService.instance.assign_team_to_courses(@team, [course], @manager)
      expect do
        delete member_path(@learner)
      end.to change(Enrollment, :count).by(-1)
    end

    it 'updates total_members_count of the team' do
      # set the total_members_count field
      Teams::UpdateTotalMembersCountService.instance.update_count(@team)

      expect do
        delete member_path(@learner)
        @team.reload
      end.to change { @team.total_members_count }.by(-1)
    end
  end
end
