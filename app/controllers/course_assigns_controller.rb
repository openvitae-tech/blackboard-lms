# frozen_string_literal: true

class CourseAssignsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_actions
  before_action :set_user_or_team
  def new
    published_courses = Course.includes([:banner_attachment]).published

    if @team_assign
      enrolled_courses_ids = @team.team_enrollments.pluck(:course_id)
      @courses = published_courses.where.not(id: enrolled_courses_ids).order(:id)
    else
      enrolled_courses_ids = @user.enrollments.pluck(:course_id)
      @courses = published_courses.where.not(id: enrolled_courses_ids).order(:id)
    end
  end

  def create
    course_ids = (params[:course_ids] || []).filter { |id| !id.empty? }
    deadlines = (params[:duration] || []).map { |d| to_deadline(d) }

    if course_ids.empty?
      flash.now[:error] = 'No courses selected'
      return render
    end

    courses = Course.find(course_ids)

    courses_with_deadline = courses.zip(deadlines)
    service = CourseManagementService.instance

    if @team_assign
      service.assign_team_to_courses(@team, courses_with_deadline, current_user)
    else
      service.assign_user_to_courses(@user, courses_with_deadline, current_user)
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

  def to_deadline(duration)
    case duration
    when 'one_day'
      DateTime.now + 1.day
    when 'two_days'
      DateTime.now + 2.days
    when 'one_week'
      DateTime.now + 1.week
    when 'two_weeks'
      DateTime.now + 2.weeks
    when 'one_month'
      DateTime.now + 1.month
    else
      nil
    end
  end
end
