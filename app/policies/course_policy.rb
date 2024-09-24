# frozen_string_literal: true

class CoursePolicy
  attr_reader :user, :course

  def initialize(user, course)
    @user = user
    @course = course
  end

  def new?
    user.is_admin?
  end

  def create?
    user.is_admin?
  end

  def show?
    user.present?
  end

  def update?
    user.is_admin?
  end

  def edit?
    user.is_admin?
  end

  def destroy?
    false
  end

  def enroll?
    user.present? && !user.is_admin? && !user.enrolled_for_course?(course)
  end

  def unenroll?
    user.present? && !user.is_admin? && user.enrolled_for_course?(course)
  end

  def proceed?
    user.present? && user.enrolled_for_course?(course)
  end

  def publish?
    user.present? && user.is_admin? && !course.published?
  end

  def unpublish?
    user.present? && user.is_admin? && course.published?
  end
end
