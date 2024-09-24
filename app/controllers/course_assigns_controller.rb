# frozen_string_literal: true

class CourseAssignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  def list
    authorize :course_assigns
    enrolled_courses = @user.courses
    @courses = Course.all - enrolled_courses
  end

  def assign
    authorize :course_assigns
    course_ids = params[:course_ids].filter { |id| !id.empty? }
    courses = Course.find(course_ids)
    CourseManagementService.instance.assign_user_to_courses(@user, courses, current_user)
  end

  private

  def set_user
    @user = User.find params[:user_id]
  end
end
