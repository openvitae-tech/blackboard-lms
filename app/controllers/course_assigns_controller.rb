# frozen_string_literal: true

class CourseAssignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_or_team
  def new
    authorize :course_assigns

    if @team_assign
      @courses = Course.all
    else
      enrolled_courses = @user.courses
      @courses = Course.all - enrolled_courses
    end
  end

  def create
    authorize :course_assigns
    course_ids = params[:course_ids].filter { |id| !id.empty? }
    deadlines = params[:duration].map { |d| to_deadline(d) }
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

  def set_user_or_team
    @user = User.find params[:user_id] if params[:user_id].present?
    @team = Team.find params[:team_id] if params[:team_id].present?

    @team_assign = @team.present?
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
      begin
        date = DateTime.strptime(duration, '%Y-%m-%d').end_of_day
      rescue ArgumentError
        Rails.logger.error "Invalid date format for #{duration} for course deadline, using default 1 month duration"
        date = DateTime.now + 1.month
      end
      date
    end
  end
end
