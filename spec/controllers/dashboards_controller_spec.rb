# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardsController, type: :controller do
  let(:learning_partner) { create(:learning_partner) }
  let(:team) { create(:team, learning_partner:) }
  let(:manager) { create(:user, :manager, t_team: team) }
  let(:learner) { create(:user, :learner, t_team: team) }
  let(:mock_dashboard) { instance_double(Dashboard) }

  before do
    sign_in manager
    allow(DashboardService.instance).to receive(:build_dashboard_for).and_return(mock_dashboard)
  end

  describe 'GET #team_progress' do
    before do
      allow(mock_dashboard).to receive(:all_team_members_progress).and_return([])
      allow(mock_dashboard).to receive(:team_member_status_counts).and_return({ completed: 0, behind: 0 })
    end

    it 'assigns @team_members with paginated results' do
      get :team_progress, params: { team_id: team.id }
      expect(assigns(:team_members)).to eq([])
    end

    it 'passes query param to the dashboard' do
      get :team_progress, params: { team_id: team.id, query: 'Alice' }
      expect(mock_dashboard).to have_received(:all_team_members_progress).with(nil, query: 'Alice')
    end

    it 'renders successfully' do
      get :team_progress, params: { team_id: team.id }
      expect(response).to be_successful
    end

    it 'redirects learners to the 401 page' do
      sign_in learner
      get :team_progress, params: { team_id: team.id }
      expect(response).to redirect_to(error_401_path)
    end
  end

  describe 'GET #team_member_profile' do
    let(:target_learner) { create(:user, :learner, t_team: team) }

    before do
      allow(mock_dashboard).to receive(:team_member_data).and_return({})
    end

    it 'finds and assigns @member' do
      get :team_member_profile, params: { team_id: team.id, user_id: target_learner.id }
      expect(assigns(:member)).to eq(target_learner)
    end

    it 'assigns @member_data from the dashboard' do
      allow(mock_dashboard).to receive(:team_member_data).with(target_learner).and_return({ courses_count: 2 })
      get :team_member_profile, params: { team_id: team.id, user_id: target_learner.id }
      expect(assigns(:member_data)).to eq({ courses_count: 2 })
    end

    it 'renders successfully' do
      get :team_member_profile, params: { team_id: team.id, user_id: target_learner.id }
      expect(response).to be_successful
    end

    it 'redirects learners to the 401 page' do
      sign_in learner
      get :team_member_profile, params: { team_id: team.id, user_id: target_learner.id }
      expect(response).to redirect_to(error_401_path)
    end
  end

  describe 'GET #started_vs_completed' do
    let(:gap_item) { { course: create(:course), total: 5, completed: 2 } }

    before do
      allow(mock_dashboard).to receive_messages(widest_gap_courses: [gap_item], all_started_vs_completed: [])
    end

    it 'assigns @widest_gap_courses' do
      get :started_vs_completed, params: { team_id: team.id }
      expect(assigns(:widest_gap_courses)).to eq([gap_item])
    end

    it 'assigns @courses excluding widest gap course ids' do
      get :started_vs_completed, params: { team_id: team.id }
      expect(mock_dashboard).to have_received(:all_started_vs_completed)
        .with(nil, exclude_ids: [gap_item[:course].id], query: nil)
    end

    it 'passes query param' do
      get :started_vs_completed, params: { team_id: team.id, query: 'Ruby' }
      expect(mock_dashboard).to have_received(:all_started_vs_completed)
        .with(nil, exclude_ids: [gap_item[:course].id], query: 'Ruby')
    end

    it 'renders successfully' do
      get :started_vs_completed, params: { team_id: team.id }
      expect(response).to be_successful
    end

    it 'redirects learners to the 401 page' do
      sign_in learner
      get :started_vs_completed, params: { team_id: team.id }
      expect(response).to redirect_to(error_401_path)
    end
  end

  describe 'GET #recent_activity' do
    before do
      allow(mock_dashboard).to receive(:all_recent_activity).and_return([])
    end

    it 'assigns @activities with paginated activity data' do
      get :recent_activity, params: { team_id: team.id }
      expect(assigns(:activities)).to eq([])
    end

    it 'passes page param to the dashboard' do
      get :recent_activity, params: { team_id: team.id, page: '2' }
      expect(mock_dashboard).to have_received(:all_recent_activity).with('2')
    end

    it 'renders successfully' do
      get :recent_activity, params: { team_id: team.id }
      expect(response).to be_successful
    end

    it 'redirects learners to the 401 page' do
      sign_in learner
      get :recent_activity, params: { team_id: team.id }
      expect(response).to redirect_to(error_401_path)
    end
  end

  describe 'nudge_all' do
    let(:course) { create(:course) }
    let(:target_learner) { create(:user, :learner, t_team: team) }

    before do
      allow(mock_dashboard).to receive(:falling_behind_learners).and_return([])
      allow(UserMailer).to receive(:course_deadline_reminder)
        .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: nil))
      allow(NotificationService).to receive(:notify)
    end

    describe 'GET' do
      it 'renders the nudge_all template without sending notifications' do
        get :nudge_all, params: { team_id: team.id }
        expect(NotificationService).not_to have_received(:notify)
        expect(response).to be_successful
      end
    end

    describe 'POST with course_id' do
      let!(:enrollment) do
        Enrollment.create!(user: target_learner, course:, course_completed: false,
                           deadline_at: 2.days.from_now)
      end

      it 'sends notifications only to that course incomplete learners' do
        post :nudge_all, params: { team_id: team.id, course_id: course.id }
        expect(NotificationService).to have_received(:notify).with(target_learner, anything, anything, anything)
      end

      it 'sends deadline reminder mail to each learner' do
        post :nudge_all, params: { team_id: team.id, course_id: course.id }
        expect(UserMailer).to have_received(:course_deadline_reminder)
          .with(target_learner, course, enrollment.deadline_at)
      end

      it 'does not notify learners who completed the course' do
        enrollment.update!(course_completed: true)
        post :nudge_all, params: { team_id: team.id, course_id: course.id }
        expect(NotificationService).not_to have_received(:notify)
      end

      it 'redirects to dashboards_path with a success flash' do
        post :nudge_all, params: { team_id: team.id, course_id: course.id }
        expect(response).to redirect_to(dashboards_path)
        expect(flash[:success]).to match(/Nudge sent to/)
      end
    end

    describe 'POST without course_id' do
      let(:falling_behind_enrollment) do
        Enrollment.create!(user: target_learner, course:, course_completed: false, deadline_at: 3.days.from_now)
      end

      it 'sends notifications to all falling behind learners' do
        allow(mock_dashboard).to receive(:falling_behind_learners)
          .and_return([falling_behind_enrollment])
        post :nudge_all, params: { team_id: team.id }
        expect(NotificationService).to have_received(:notify).with(target_learner, anything, anything, anything)
      end

      it 'redirects to dashboards_path with a success flash' do
        post :nudge_all, params: { team_id: team.id }
        expect(response).to redirect_to(dashboards_path)
        expect(flash[:success]).to match(/Nudge sent to/)
      end
    end
  end

  describe 'appreciate_member' do
    let(:target_learner) { create(:user, :learner, t_team: team) }

    before do
      allow(NotificationService).to receive(:notify)
    end

    describe 'GET' do
      it 'assigns @member and @banner_type' do
        get :appreciate_member, params: { team_id: team.id, user_id: target_learner.id, banner_type: 'crushing_it' }
        expect(assigns(:member)).to eq(target_learner)
        expect(assigns(:banner_type)).to eq('crushing_it')
      end

      it 'renders without sending a notification' do
        get :appreciate_member, params: { team_id: team.id, user_id: target_learner.id, banner_type: 'crushing_it' }
        expect(NotificationService).not_to have_received(:notify)
        expect(response).to be_successful
      end

      it 'redirects learners to the 401 page' do
        sign_in learner
        get :appreciate_member, params: { team_id: team.id, user_id: target_learner.id }
        expect(response).to redirect_to(error_401_path)
      end
    end

    describe 'POST' do
      it 'sends a notification to the member' do
        post :appreciate_member, params: {
          team_id: team.id, user_id: target_learner.id,
          banner_type: 'crushing_it', message: 'Great work!'
        }
        expect(NotificationService).to have_received(:notify)
          .with(target_learner, 'Your manager appreciates you!', 'Great work!')
      end

      it 'sends a reminder notification for falling_behind banner' do
        post :appreciate_member, params: {
          team_id: team.id, user_id: target_learner.id,
          banner_type: 'falling_behind', message: 'Keep going!'
        }
        expect(NotificationService).to have_received(:notify)
          .with(target_learner, 'Reminder from your manager', 'Keep going!')
      end

      it 'redirects to team member profile with a success flash' do
        post :appreciate_member, params: {
          team_id: team.id, user_id: target_learner.id,
          banner_type: 'crushing_it', message: 'Well done!'
        }
        expect(response).to redirect_to(team_member_profile_dashboards_path(user_id: target_learner.id,
                                                                            team_id: team.id))
        expect(flash[:success]).to include(target_learner.display_name)
      end
    end
  end

  describe 'set_dashboard_params' do
    before { allow(mock_dashboard).to receive_messages(all_team_members_progress: [], team_member_status_counts: { completed: 0, behind: 0 }) }

    it 'uses current_user team_id when no team_id param is given' do
      get :team_progress
      expect(assigns(:team)).to eq(manager.team)
    end

    it 'parses custom date range from from_date and to_date params' do
      get :team_progress, params: {
        team_id: team.id, duration: 'custom',
        from_date: '2024-01-01', to_date: '2024-03-31'
      }
      duration = assigns(:duration)
      expect(duration).to be_a(Range)
      expect(duration.begin).to eq(Date.parse('2024-01-01').beginning_of_day)
      expect(duration.end).to eq(Date.parse('2024-03-31').end_of_day)
    end

    it 'uses VALID_DURATIONS first key as default when no duration param' do
      get :team_progress, params: { team_id: team.id }
      expect(assigns(:duration)).to eq(Dashboard::VALID_DURATIONS.first[0])
    end
  end
end
