# frozen_string_literal: true

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
    false
  end

  def complete?
    return false unless user.enrolled_for_course?(record.course_module.course)

    enrollment = user.get_enrollment_for(record.course_module.course)
    !enrollment.completed_lessons.include?(record.id)
  end

  def moveup?
    user.is_admin?
  end

  def movedown?
    user.is_admin?
  end

  # Note: avoid using this in view policy(lesson).replay? could trigger n+1 queries
  def replay?
    return false unless user.enrolled_for_course?(record.course_module.course)

    enrollment = user.get_enrollment_for(record.course_module.course)
    enrollment.completed_lessons.include?(record.id)
  end
end
