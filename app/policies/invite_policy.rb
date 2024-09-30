# frozen_string_literal: true

class InvitePolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    super
    @user = user
    @record = record
  end

  def new?
    user.is_admin? || user.is_manager? || user.is_owner?
  end

  def new_admin?
    user.is_admin?
  end

  def create?
    return true if user.is_admin?

    return record.team_hierarchy.include?(user.team) if user.is_manager? || user.is_owner?

    false
  end

  def create_admin?
    user.is_admin?
  end

  def resend?
    # record is the other user whom the current user want to send a re-invite
    !record.verified? && (user.is_admin? || user.is_manager? || user.is_owner?)
  end
end
