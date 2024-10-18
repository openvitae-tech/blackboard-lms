# frozen_string_literal: true

class TeamPolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    super
    @user = user
    @record = record
  end

  def new?
    user.is_manager? || user.is_owner?
  end

  def show?
    user.is_manager? || user.is_owner?
  end

  def create?
    user.is_manager? || user.is_owner?
  end

  def update?
    user.is_manager? || user.is_owner?
  end

  def edit?
    user.is_manager? || user.is_owner?
  end

  def destroy?
    false
  end
end
