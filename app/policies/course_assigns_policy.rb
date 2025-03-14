# frozen_string_literal: true

class CourseAssignsPolicy
  attr_reader :user, :course

  def initialize(user, course)
    @user = user
    @course = course
  end

  def new?
    user.privileged_user?
  end

  def create?
    user.privileged_user?
  end
end
