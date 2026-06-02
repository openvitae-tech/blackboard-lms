# frozen_string_literal: true

class QuestionPolicy
  attr_reader :user, :question

  def initialize(user, record)
    @user = user
    @question = record
  end

  def index?
    user.is_admin? || user.privileged_user?
  end

  def new?
    user.is_admin? || user.privileged_user?
  end

  def create?
    user.is_admin? || user.privileged_user?
  end

  def generate?
    user.is_admin? || user.privileged_user?
  end

  def update?
    user.is_admin? || own_content_studio_question?
  end

  def edit?
    user.is_admin? || own_content_studio_question?
  end

  def destroy?
    user.is_admin? || own_content_studio_question?
  end

  def verify?
    user.is_admin? || own_content_studio_question?
  end

  def unverify?
    user.is_admin? || own_content_studio_question?
  end

  private

  def own_content_studio_question?
    user.privileged_user? && CoursePolicy.new(user, question.course).edit?
  end
end
