# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request spec for GET /courses/manage' do
  describe 'accessing manage page by privileged user' do
    %i[manager owner].each do |role|
      context "when accessed as #{role}" do
        before do
          @team = create :team
          @user = create :user, role, team: @team
          @user.update!(content_studio_creator: true)
          create :payment_plan, learning_partner: @user.learning_partner, content_studio_enabled: true
          sign_in @user
        end

        it 'successfully renders the manage page' do
          get(manage_courses_path)
          expect(response).to render_template(:manage)
        end

        it 'shows only Content Studio courses for the learning partner' do
          lp = @user.learning_partner
          own_course = create(:course, neo_ai_course_id: 'cs-own', learning_partner: lp)
          other_course = create(:course, neo_ai_course_id: 'cs-other', learning_partner: create(:learning_partner))
          regular_course = create(:course)

          get(manage_courses_path)

          ids = assigns(:courses).pluck(:id)
          expect(ids).to include(own_course.id)
          expect(ids).not_to include(other_course.id)
          expect(ids).not_to include(regular_course.id)
        end
      end
    end
  end

  describe 'access control' do
    it 'redirects learners away from manage page' do
      team = create :team
      learner = create :user, :learner, team: team
      sign_in learner

      get(manage_courses_path)
      expect(response).to redirect_to(error_401_path)
    end
  end
end
