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
    return false unless other_user.deactivated?
    return false unless user.manager_of?(other_user)

    partner = other_user.learning_partner
    partner.active_users_count < partner.payment_plan.total_seats
  end

  def confirm_activate?
    activate?
  end

  def destroy?
    user.manager_of?(other_user) && (other_user.unverified? || other_user.verified?)
  end
end
