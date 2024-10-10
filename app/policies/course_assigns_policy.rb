# frozen_string_literal: true

class CourseAssignsPolicy
  attr_reader :user, :course

  def initialize(user, course)
    @user = user
    @course = course
  end

  def new?
    user.is_owner? || user.is_manager?
  end

  def create?
    user.is_owner? || user.is_manager?
  end
end
