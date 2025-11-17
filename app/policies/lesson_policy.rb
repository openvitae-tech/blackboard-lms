# frozen_string_literal: true

class LessonPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def new?
    user.is_admin?
  end

  def show?
    user.is_admin? || user.enrolled_for_course?(record)
  end

  def create?
    user.is_admin?
  end

  def update?
    user.is_admin?
  end

  def edit?
    user.is_admin?
  end

  def destroy?
    return false unless user.is_admin?

    course = record.course_module.course
    CoursePolicy.new(user, course).destroy?
  end

  def complete?
    user.enrolled_for_course?(record.course_module.course)
  end

  def moveup?
    user.is_admin?
  end

  def movedown?
    user.is_admin?
  end

  def transcribe?
    user.is_admin?
  end
end
