# frozen_string_literal: true

class MyProfilePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def show?
    user.is_learner?
  end
end
