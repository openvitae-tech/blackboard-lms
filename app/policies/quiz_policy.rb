class QuizPolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def new?
    user.is_admin?
  end

  def show?
    user.is_admin? || user.enrolled_for_course?(record.course_module.course)
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

  def submit_answer?
    return false if !user.present? && user.enrolled_for_course?(record.course_module.course)
    enrollment = user.get_enrollment_for(record.course_module.course) if user.enrolled_for_course?(record.course_module.course)
    !enrollment.quiz_answered?(record)
  end

  def moveup?
    user.is_admin?
  end

  def movedown?
    user.is_admin?
  end
end