# frozen_string_literal: true

class CourseAssignsController < ApplicationController
  before_action -> { @active_nav = 'teams' }
  before_action :authorize_actions
  before_action :set_user_or_team

  include SearchContextHelper

  def new
    context = @team_assign ? SearchContext::TEAM_ASSIGN : SearchContext::USER_ASSIGN
    @search_context = build_search_context(context:, resource: @team || @user)
    service = Courses::FilterService.new(current_user, @search_context)
    @courses = service.filter.records.includes(:banner_attachment, :tags).page(params[:page]).per(Course::PER_PAGE_LIMIT)
    @tags = Tag.load_tags
  end

  def create
    permitted = params.permit(course_ids: [], durations: {}, custom_dates: {})
    course_ids = (permitted[:course_ids] || []).reject(&:blank?)

    if course_ids.empty?
      flash.now[:error] = 'No courses selected'
      return render
    end

    durations_hash = permitted.fetch(:durations, {})
    custom_dates_hash = permitted.fetch(:custom_dates, {})
    courses = Course.find(course_ids)

    @courses_with_deadline = courses.map do |course|
      id = course.id.to_s
      [course, to_deadline(durations_hash[id], custom_dates_hash[id])]
    end

    if @courses_with_deadline.any? { |course, dl| durations_hash[course.id.to_s] == 'custom' && dl.nil? }
      flash.now[:error] = 'One or more custom dates are invalid'
      return render status: :unprocessable_entity
    end

    service = Courses::ManagementService.instance

    if @team_assign
      service.assign_team_to_courses(@team, @courses_with_deadline, current_user)
    else
      service.assign_user_to_courses(@user, @courses_with_deadline, current_user)
    end

    flash.now[:success] = 'Courses assigned successfully'
  end

  private

  def authorize_actions
    authorize :course_assigns
  end

  def set_user_or_team
    # either user_id or team_id will be present not both
    @user = User.find params[:user_id] if params[:user_id].present?
    @team = Team.find params[:team_id] if params[:team_id].present?

    if @team.present?
      @team_assign = true
      raise Errors::IllegalAccessError.new("User does not belong to the team hierarchy") unless @team.within_hierarchy?(current_user)
    else
      raise Errors::IllegalAccessError.new("User does not belong to the team hierarchy") unless @user.team.within_hierarchy?(current_user)
    end
  end

  def to_deadline(duration, custom_date = nil)
    if duration == 'custom'
      return nil if custom_date.blank?

      begin
        DateTime.parse(custom_date)
      rescue ArgumentError
        nil
      end
    else
      case duration
      when 'one_day' then Time.current + 1.day
      when 'two_days' then Time.current + 2.days
      when 'one_week' then Time.current + 1.week
      when 'two_weeks' then Time.current + 2.weeks
      when 'one_month' then Time.current + 1.month
      end
    end
  end
end
