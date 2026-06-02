# frozen_string_literal: true

class LessonPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def new?
    user.is_admin? || user.privileged_user?
  end

  def show?
    user.is_admin? || own_content_studio_lesson? || user.enrolled_for_course?(record)
  end

  def create?
    user.is_admin? || user.privileged_user?
  end

  def update?
    user.is_admin? || own_content_studio_lesson?
  end

  def edit?
    user.is_admin? || own_content_studio_lesson?
  end

  def destroy?
    course = record.course_module.course
    CoursePolicy.new(user, course).destroy?
  end

  def complete?
    user.enrolled_for_course?(record.course_module.course)
  end

  def moveup?
    user.is_admin? || own_content_studio_lesson?
  end

  def movedown?
    user.is_admin? || own_content_studio_lesson?
  end

  def transcribe?
    user.is_admin?
  end

  private

  def own_content_studio_lesson?
    user.privileged_user? && CoursePolicy.new(user, record.course_module.course).edit?
  end
end
