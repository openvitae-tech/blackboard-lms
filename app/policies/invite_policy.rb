# frozen_string_literal: true

class InvitePolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
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
    user.is_admin? || user.is_manager? || user.is_owner?
  end

  def create_admin?
    user.is_admin?
  end

  def resend?
    # record is the other user whom the current user want to send a re-invite
    !record.verified? && (user.is_admin? || user.is_manager? || user.is_owner?)
  end
end
