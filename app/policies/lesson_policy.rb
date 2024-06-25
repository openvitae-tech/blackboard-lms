class LessonPolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def new?
    user.is_admin?
  end

  def show?
    user.present?
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
    user.is_admin?
  end

  def complete?
    return false unless user.enrolled_for_course?(record.course_module.course)
    enrollment = user.get_enrollment_for(record.course_module.course)
    !enrollment.completed_lessons.include?(record.id)
  end
end