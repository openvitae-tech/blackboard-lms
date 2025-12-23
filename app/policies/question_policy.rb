# frozen_string_literal: true

class QuestionPolicy
  attr_reader :user, :question

  def initialize(user, record)
    @user = user
    @question = record
  end

  def index?
    user.is_admin?
  end

  def new?
    user.is_admin?
  end

  def create?
    user.is_admin?
  end

  def generate?
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

  def verify?
    user.is_admin?
  end

  def unverify?
    user.is_admin?
  end
end
