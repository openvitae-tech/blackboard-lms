# frozen_string_literal: true

RSpec.describe 'Request spec for POST /course_assigns' do
  describe 'A manager can assign course to a user' do
    let(:team) { create :team }

    let(:manager) { create(:user, :manager, team:, learning_partner: team.learning_partner) }

    before do
      sign_in manager
      @courses = Array.new(2) { course_with_associations(published: true) }
      @learner = create(:user, :learner, team:, learning_partner: team.learning_partner)
    end

    it 'assigns the courses successfully' do
      params = {
        course_ids: @courses.map(&:id),
        duration: %w[none one_week],
        user_id: @learner.id
      }

      expect do
        post('/course_assigns', params:)
      end.to change(Enrollment, :count).by(2)

      expect(assigns[:user]).to eq(@learner)
      expect(flash['success']).to eq('Courses assigned successfully')
    end

    it 'assigns the courses successfully to team' do
      params = {
        course_ids: @courses.map(&:id),
        duration: %w[none one_week],
        team_id: team.id
      }

      expect do
        post('/course_assigns', params:)
      end.to change(TeamEnrollment, :count).by(2).and change(Enrollment, :count).by(2)

      expect(assigns[:team]).to eq(team)
      expect(flash['success']).to eq('Courses assigned successfully')
    end

    it 'sets assigned_by fields' do
      params = {
        course_ids: @courses.map(&:id),
        duration: %w[none one_week],
        team_id: team.id
      }

      post('/course_assigns', params:)

      team_enrollment = TeamEnrollment.last
      enrollment = Enrollment.last
      expect(team_enrollment.assigned_by).to eq(manager)
      expect(enrollment.assigned_by).to eq(manager)
    end

    it 'sets deadline field of enrollment' do
      params = {
        course_ids: @courses.map(&:id),
        duration: %w[none one_week],
        team_id: team.id
      }

      post('/course_assigns', params:)

      enrollment_one = Enrollment.first
      enrollment_two = Enrollment.last
      expect(enrollment_one.deadline_at).to be_nil
      expect(enrollment_two.deadline_at).not_to be_nil
    end
  end

  describe 'by admin' do
    let(:admin) { create :user, :admin }
    let(:learner) { create(:user, :learner) }

    before do
      sign_in admin
    end

    it 'fails' do
      post('/course_assigns')
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
      post('/course_assigns')
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response.status).to be(302)
    end
  end
end
