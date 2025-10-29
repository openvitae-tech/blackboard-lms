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

  def change_team?
    return false unless user.privileged_user?
    return false if changing_own_team?
    return false if changing_owner?
    return false if managers_belong_to_same_team?

    user.manager_of?(other_user)
  end

  def change_role?
    return false unless user.privileged_user?

    user.manager_of?(other_user) && user.id != other_user.id
  end

  private

  def changing_own_team?
    user.id == other_user.id
  end

  def changing_owner?
    other_user.is_owner?
  end

  def managers_belong_to_same_team?
    user.is_manager? && other_user.is_manager? && (user.team_id == other_user.team_id)
  end
end
