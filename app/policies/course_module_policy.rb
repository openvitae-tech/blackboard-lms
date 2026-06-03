# frozen_string_literal: true

class CourseModulePolicy
  attr_reader :user, :course_module

  def initialize(user, record)
    @user = user
    @course_module = record
  end

  def new?
    user.is_admin? || own_content_studio_module?
  end

  def show?
    user.is_admin? || own_content_studio_module?
  end

  def create?
    user.is_admin? || own_content_studio_module?
  end

  def update?
    user.is_admin? || own_content_studio_module?
  end

  def edit?
    user.is_admin? || own_content_studio_module?
  end

  def destroy?
    CoursePolicy.new(user, course_module.course).destroy?
  end

  def moveup?
    user.is_admin? || own_content_studio_module?
  end

  def movedown?
    user.is_admin? || own_content_studio_module?
  end

  def summary?
    true
  end

  def redo_quiz?
    true
  end

  private

  def own_content_studio_module?
    user.privileged_user? && CoursePolicy.new(user, course_module.course).edit?
  end
end
