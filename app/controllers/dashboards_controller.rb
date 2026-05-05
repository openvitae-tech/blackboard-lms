# frozen_string_literal: true

class DashboardsController < ApplicationController
  before_action :set_dashboard_params, only: %i[index nudge_all appreciate_member team_progress team_member_profile started_vs_completed recent_activity]

  def index
    authorize :dashboard

    service = DashboardService.instance
    @dashboard = service.build_dashboard_for(@team, @duration)
  end

  def team_member_profile
    authorize :dashboard
    @member = User.find(params[:user_id])
    @dashboard = DashboardService.instance.build_dashboard_for(@team, @duration)
    @member_data = @dashboard.team_member_data(@member)
  end

  def recent_activity
    authorize :dashboard
    @dashboard = DashboardService.instance.build_dashboard_for(@team, @duration)
    @activities = @dashboard.all_recent_activity(params[:page])
  end

  def started_vs_completed
    authorize :dashboard
    @dashboard = DashboardService.instance.build_dashboard_for(@team, @duration)
    @widest_gap_courses = @dashboard.widest_gap_courses
    widest_gap_ids = @widest_gap_courses.map { |item| item[:course].id }
    @courses = @dashboard.all_started_vs_completed(params[:page], exclude_ids: widest_gap_ids, query: params[:query])
  end

  def team_progress
    authorize :dashboard
    @dashboard = DashboardService.instance.build_dashboard_for(@team, @duration)
    @team_members = @dashboard.all_team_members_progress(params[:page], query: params[:query])
    @member_counts = @dashboard.team_member_status_counts
  end

  def nudge_all
    authorize :dashboard

    service = DashboardService.instance
    @dashboard = service.build_dashboard_for(@team, @duration)

    @enrollments = if params[:course_id].present?
                     Enrollment
                       .joins(:user)
                       .where(users: { team_id: @team.team_hierarchy_ids })
                       .where(course_id: params[:course_id], course_completed: false)
                       .includes(:user, :course)
                   else
                     @dashboard.falling_behind_learners
                   end

    return unless request.post?

    nudge_key = params[:course_id].present? ? 'course.nudge' : 'course.nudge_deadline'
    @enrollments.each do |enrollment|
      UserMailer.course_deadline_reminder(enrollment.user, enrollment.course, enrollment.deadline_at).deliver_later
      NotificationService.notify(
        enrollment.user,
        I18n.t("#{nudge_key}.title"),
        format(I18n.t("#{nudge_key}.text"), course: enrollment.course.title),
        link: course_path(enrollment.course)
      )
    end

    flash[:success] = "Nudge sent to #{@enrollments.count} learners"
    redirect_to dashboards_path
  end

  def appreciate_member
    authorize :dashboard
    @member = User.find(params[:user_id])
    @banner_type = params[:banner_type]

    return unless request.post?

    notification_title = @banner_type == 'crushing_it' ? 'Your manager appreciates you!' : 'Reminder from your manager'
    NotificationService.notify(@member, notification_title, params[:message].to_s.strip)

    flash[:success] = "Message sent to #{@member.display_name}"
    redirect_to team_member_profile_dashboards_path(user_id: @member.id, team_id: @team.id)
  end

  def nudge_user
    authorize :dashboard

    enrollment = Enrollment.find(params[:enrollment_id])
    UserMailer.course_deadline_reminder(enrollment.user, enrollment.course, enrollment.deadline_at).deliver_later
    NotificationService.notify(
      enrollment.user,
      I18n.t('course.nudge.title'),
      format(I18n.t('course.nudge.text'), course: enrollment.course.title),
      link: course_path(enrollment.course)
    )

    flash[:success] = "Nudge sent to #{enrollment.user.name}"
    redirect_to dashboards_path
  end

  private

  def set_dashboard_params
    team_id = params[:team_id].present? ? params[:team_id] : current_user.team_id
    @team = Team.includes(sub_teams: :sub_teams).find(team_id)

    @duration = if params[:duration] == 'custom' && params[:from_date].present? && params[:to_date].present?
                  Date.parse(params[:from_date]).beginning_of_day..Date.parse(params[:to_date]).end_of_day
                elsif params[:duration].present?
                  params[:duration]
                else
                  ::Dashboard::VALID_DURATIONS.first[0]
                end
  end
end
