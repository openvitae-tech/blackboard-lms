# frozen_string_literal: true

class UserPolicy
  attr_reader :user, :other_user

  def initialize(user, other_user)
    @user = user
    @other_user = other_user
  end

  def show?
    user.manager_of?(other_user)
  end

  def deactivate?
    other_user.active? && user.manager_of?(other_user)
  end

  def confirm_deactivate?
    deactivate?
  end

  def activate?
    other_user.deactivated? && user.manager_of?(other_user)
  end

  def confirm_activate?
    activate?
  end
end
