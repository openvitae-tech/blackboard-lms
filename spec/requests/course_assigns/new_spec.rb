# frozen_string_literal: true

RSpec.describe 'Request spec for GET /course_assigns/new' do
  describe 'A manager can assign course to a user' do
    let(:team) { create :team }
    let(:manager) { create(:user, :manager, team:, learning_partner: team.learning_partner) }
    let(:learner) { create(:user, :learner, team:, learning_partner: team.learning_partner) }

    before do
      sign_in manager
      @courses = Array.new(2) { course_with_associations(published: true) }.reverse
    end

    it 'Returns list of unassigned courses to the user to which the course is getting assigned' do
      get("/course_assigns/new?user_id=#{learner.id}")
      expect(response.status).to be(200)
      expect(assigns(:team_assign)).to be_falsey
      expect(assigns(:courses)).to eq(@courses)
    end

    it 'does not return unpublished courses' do
      course = course_with_associations(published: false)
      get("/course_assigns/new?user_id=#{learner.id}")
      expect(assigns(:courses)).not_to include(course)
    end

    it 'for team assignment @team_assign is set and returns unassigned courses for the team' do
      get("/course_assigns/new?team_id=#{team.id}")
      expect(assigns(:team_assign)).to be_truthy
      expect(assigns(:courses)).to eq(@courses)
    end

    it 'for team assignment filters out previously enrolled courses' do
      course = course_with_associations(published: false)
      course.enroll_team!(team, manager)
      get("/course_assigns/new?team_id=#{team.id}")
      expect(assigns(:team_assign)).to be_truthy
      expect(assigns(:courses)).not_to include(course)
    end
  end

  describe 'by admin' do
    let(:admin) { create :user, :admin }
    let(:learner) { create(:user, :learner) }

    before do
      sign_in admin
    end

    it 'fails' do
      get("/course_assigns/new?user_id=#{learner.id}")
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response.status).to be(302)
    end
  end

  describe 'by learner' do
    let(:learner_one) { create(:user, :learner) }
    let(:learner_two) { create :user, :learner }

    before do
      sign_in learner_two
    end

    it 'fails' do
      get("/course_assigns/new?user_id=#{learner_two.id}")
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response.status).to be(302)
    end
  end
end
