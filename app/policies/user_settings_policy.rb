# frozen_string_literal: true

class UserSettingsPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def show?
    user.present?
  end

  def edit?
    user.present?
  end

  def update?
    user.present?
  end

  def change_password?
    user.present?
  end

  def update_password?
    user.present?
  end

  def team?
    user.present?
  end
end
