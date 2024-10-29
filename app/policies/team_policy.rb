# frozen_string_literal: true

class TeamPolicy < ApplicationPolicy
  attr_reader :user, :team

  def initialize(user, team)
    super
    @user = user
    @team = record
  end

  def new?
    manager_or_owner?
  end

  def show?
    manager_or_owner? && user_included_in_subteam?
  end

  def create?
    manager_or_owner? && user_included_in_subteam?
  end

  def update?
    manager_or_owner? && user_included_in_subteam?
  end

  def edit?
    manager_or_owner? && user_included_in_subteam?
  end

  def destroy?
    false
  end

  private

  def manager_or_owner?
    user.is_manager? || user.is_owner?
  end

  def user_included_in_subteam?
    user.team == @team || @team.ancestors.include?(user.team)
  end
end
