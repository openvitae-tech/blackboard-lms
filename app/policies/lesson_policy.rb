# frozen_string_literal: true

class LessonPolicy < ApplicationPolicy
  attr_reader :user, :lesson

  def initialize(user, record)
    @user = user
    @lesson = record
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
    return false unless user.is_admin?

    course = lesson.course_module.course
    CoursePolicy.new(user, course).destroy?
  end

  def complete?
    user.enrolled_for_course?(lesson.course_module.course) ? true : false
  end

  def moveup?
    user.is_admin?
  end

  def movedown?
    user.is_admin?
  end

  # Note: avoid using this in view policy(lesson).replay? could trigger n+1 queries
  def replay?
    return false unless user.enrolled_for_course?(lesson.course_module.course)

    enrollment = user.get_enrollment_for(lesson.course_module.course)
    enrollment.completed_lessons.include?(record.id)
  end
end
