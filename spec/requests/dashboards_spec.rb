# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboards', type: :request do
  let(:team)    { create(:team) }
  let(:manager) { create(:user, :manager, team:, learning_partner: team.learning_partner) }
  let(:learner) { create(:user, :learner, t_team: team) }
  let(:course)  { create(:course, :published) }

  before { sign_in manager }

  # ---------------------------------------------------------------------------
  # POST #nudge_all
  # ---------------------------------------------------------------------------
  describe 'POST #nudge_all' do
    context 'when nudging all learners behind on a specific course' do
      let!(:incomplete_enrollment) do
        create(:enrollment, user: learner, course:, course_completed: false,
                            deadline_at: 3.days.from_now)
      end

      before do
        create(:enrollment, user: learner, course: create(:course, :published),
                            course_completed: true, deadline_at: 3.days.from_now)
      end

      it 'sends a notification only to incomplete learners for that course' do
        allow(NotificationService).to receive(:notify)
        post nudge_all_dashboards_path(course_id: course.id)
        expect(NotificationService).to have_received(:notify).once
      end

      it 'enqueues a mailer for the incomplete learner' do
        expect do
          post nudge_all_dashboards_path(course_id: course.id)
        end.to have_enqueued_mail(UserMailer, :course_deadline_reminder)
      end

      it 'redirects to dashboards path with a success flash' do
        post nudge_all_dashboards_path(course_id: course.id)
        expect(response).to redirect_to(dashboards_path)
        expect(flash[:success]).to be_present
      end

      it 'does not re-nudge a learner nudged within the last 23 hours' do
        incomplete_enrollment.update!(reminder_send_at: 1.hour.ago)
        allow(NotificationService).to receive(:notify)
        post nudge_all_dashboards_path(course_id: course.id)
        expect(NotificationService).not_to have_received(:notify)
      end
    end

    context 'when nudging all falling-behind learners (no course_id)' do
      before do
        create(:enrollment, user: learner, course:, course_completed: false,
                            deadline_at: 3.days.from_now)
      end

      it 'sends notifications to all falling-behind learners' do
        allow(NotificationService).to receive(:notify)
        post nudge_all_dashboards_path
        expect(NotificationService).to have_received(:notify).at_least(:once)
      end

      it 'redirects with a success flash' do
        post nudge_all_dashboards_path
        expect(response).to redirect_to(dashboards_path)
        expect(flash[:success]).to be_present
      end
    end

    context 'when a learner tries to access nudge_all' do
      before { sign_in learner }

      it 'is unauthorized' do
        post nudge_all_dashboards_path
        expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      end
    end
  end
end
