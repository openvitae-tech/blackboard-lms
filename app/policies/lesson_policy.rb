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
    user.is_admin? || partner_content_studio_lesson? || user.enrolled_for_course?(record.course_module.course)
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

  private

  def partner_content_studio_lesson?
    return false unless user.privileged_user?

    course = record.course_module.course
    user.learning_partner.content_studio_enabled? &&
      course.neo_ai_course_id.present? &&
      course.learning_partner_id == user.learning_partner_id
  end
end
