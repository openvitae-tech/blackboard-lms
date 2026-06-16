# frozen_string_literal: true

class QuizPolicy
  attr_reader :user, :quiz

  def initialize(user, record)
    @user = user
    @quiz = record
  end

  def new?
    user.is_admin? || own_content_studio_quiz?
  end

  def show?
    user.is_admin? || user.enrolled_for_course?(quiz.course_module.course)
  end

  def create?
    user.is_admin? || own_content_studio_quiz?
  end

  def generate?
    user.is_admin? || own_content_studio_quiz?
  end

  def update?
    user.is_admin? || own_content_studio_quiz?
  end

  def edit?
    user.is_admin? || own_content_studio_quiz?
  end

  def destroy?
    course = quiz.course_module.course
    CoursePolicy.new(user, course).destroy?
  end

  def submit_answer?
    user.enrolled_for_course?(quiz.course_module.course)
  end

  def moveup?
    user.is_admin? || own_content_studio_quiz?
  end

  def movedown?
    user.is_admin? || own_content_studio_quiz?
  end

  private

  def own_content_studio_quiz?
    return false unless user.privileged_user?

    CoursePolicy.new(user, quiz.course_module.course).edit?
  end
end
