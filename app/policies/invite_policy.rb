# frozen_string_literal: true

class InvitePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def new?
    user.is_admin? || user.privileged_user?
  end

  def new_admin?
    user.is_admin?
  end

  def create?
    return true if user.is_admin? && record.learning_partner.payment_plan.present?

    if user.privileged_user? && record.learning_partner.payment_plan.present?
      return record.ancestors.include?(user.team)
    end

    false
  end

  def create_admin?
    user.is_admin?
  end

  def resend?
    # record is the other user whom the current user want to send a re-invite
    user.active? && record.unverified? && (user.is_admin? || user.privileged_user?)
  end
end
