# frozen_string_literal: true

class CoursePolicy
  attr_reader :user, :course

  def initialize(user, course)
    @user = user
    @course = course
  end

  def index?
    user.present?
  end

  def new?
    user.is_admin?
  end

  def create?
    user.is_admin?
  end

  def show?
    return true if user.is_admin?
    @course.published? || user.enrolled_for_course?(course)
  end

  def update?
    user.is_admin?
  end

  def edit?
    user.is_admin?
  end

  def destroy?
    # course should not be published and should not have any enrollments
    user.is_admin? && !course.published? && !course.has_enrollments?
  end

  def enroll?
    !user.is_admin? && !user.enrolled_for_course?(course)
  end

  def unenroll?
    !user.is_admin? && user.enrolled_for_course?(course)
  end

  def proceed?
    user.enrolled_for_course?(course)
  end

  def publish?
    user.is_admin? && !course.published?
  end

  def unpublish?
    user.is_admin? && course.published?
  end

  def search?
    user.present?
  end
end
