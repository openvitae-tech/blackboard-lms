# frozen_string_literal: true

class LessonRatingPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def new?
    !user.is_admin?
  end

  def create?
    !user.is_admin?
  end
end
