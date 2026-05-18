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
        Enrollment.create!(user: learner, course:, course_completed: false,
                           deadline_at: 3.days.from_now)
      end

      before do
        Enrollment.create!(user: learner, course: create(:course, :published),
                           course_completed: true, deadline_at: 3.days.from_now)
      end

      it 'sends a notification only to incomplete learners for that course' do
        allow(NotificationService).to receive(:notify)
        post nudge_all_dashboards_path(course_id: course.id)
        expect(NotificationService).to have_received(:notify).once
      end

      it 'enqueues a mailer for the incomplete learner' do
        ActiveJob::Base.queue_adapter = :test
        expect do
          post nudge_all_dashboards_path(course_id: course.id)
        end.to have_enqueued_mail(UserMailer, :course_deadline_reminder)
      ensure
        ActiveJob::Base.queue_adapter = :sidekiq
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
        Enrollment.create!(user: learner, course:, course_completed: false,
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

  # ---------------------------------------------------------------------------
  # GET #export
  # ---------------------------------------------------------------------------
  describe 'GET #export' do
    let(:fake_xlsx) { 'fake-xlsx-binary' }
    let(:mock_dashboard) { instance_double(Dashboard) }
    let(:export_service) { instance_double(DashboardExportService, generate: fake_xlsx) }

    before do
      allow(DashboardService.instance).to receive(:build_dashboard_for).and_return(mock_dashboard)
      allow(DashboardExportService).to receive(:new).and_return(export_service)
    end

    context 'when a manager requests the export' do
      it 'responds with a successful xlsx download' do
        get export_dashboards_path(team_id: team.id)
        expect(response).to be_successful
        expect(response.content_type).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      end

      it 'sets a filename containing the team name and today\'s date' do
        get export_dashboards_path(team_id: team.id)
        disposition = response.headers['Content-Disposition']
        expect(disposition).to include("dashboard-#{team.name.parameterize}")
        expect(disposition).to include("#{Time.zone.today}.xlsx")
      end

      it 'delegates to DashboardExportService with the built dashboard' do
        get export_dashboards_path(team_id: team.id)
        expect(DashboardExportService).to have_received(:new).with(mock_dashboard, team, anything)
        expect(export_service).to have_received(:generate)
      end
    end

    context 'when a learner requests the export' do
      before { sign_in learner }

      it 'is unauthorized' do
        get export_dashboards_path(team_id: team.id)
        expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GET #export_member
  # ---------------------------------------------------------------------------
  describe 'GET #export_member' do
    let(:fake_xlsx) { 'fake-xlsx-binary' }
    let(:mock_dashboard) { instance_double(Dashboard) }
    let(:member_service) { instance_double(MemberExportService, generate: fake_xlsx) }
    let(:member_data) { { courses_count: 2 } }

    before do
      allow(DashboardService.instance).to receive(:build_dashboard_for).and_return(mock_dashboard)
      allow(mock_dashboard).to receive(:team_member_data).and_return(member_data)
      allow(MemberExportService).to receive(:new).and_return(member_service)
    end

    context 'when a manager requests a member export' do
      it 'responds with a successful xlsx download' do
        get export_member_dashboards_path(team_id: team.id, user_id: learner.id)
        expect(response).to be_successful
        expect(response.content_type).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      end

      it 'sets a filename containing the member name and today\'s date' do
        get export_member_dashboards_path(team_id: team.id, user_id: learner.id)
        disposition = response.headers['Content-Disposition']
        expect(disposition).to include("member-#{learner.display_name.parameterize}")
        expect(disposition).to include("#{Time.zone.today}.xlsx")
      end

      it 'delegates to MemberExportService with the member and their data' do
        get export_member_dashboards_path(team_id: team.id, user_id: learner.id)
        expect(MemberExportService).to have_received(:new).with(learner, member_data, mock_dashboard, team)
        expect(member_service).to have_received(:generate)
      end
    end

    context 'when the user_id does not belong to the manager\'s team hierarchy' do
      let(:other_team)    { create(:team) }
      let(:other_learner) { create(:user, :learner, t_team: other_team) }

      it 'raises ActiveRecord::RecordNotFound' do
        expect do
          get export_member_dashboards_path(team_id: team.id, user_id: other_learner.id)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when a learner requests the export' do
      before { sign_in learner }

      it 'is unauthorized' do
        get export_member_dashboards_path(team_id: team.id, user_id: learner.id)
        expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      end
    end
  end
end
