# frozen_string_literal: true

class TeamPolicy < ApplicationPolicy
  attr_reader :user, :team

  def initialize(user, team)
    super
    @user = user
    @team = record
  end

  def new?
    user.privileged_user?
  end

  def show?
    user.privileged_user? && user_included_in_subteam?
  end

  def create?
    user.privileged_user? && user_included_in_subteam?
  end

  def update?
    user.privileged_user? && user_included_in_subteam?
  end

  def edit?
    user.privileged_user? && user_included_in_subteam?
  end

  def destroy?
    false
  end

  private

  def user_included_in_subteam?
    user.team == @team || @team.ancestors.include?(user.team)
  end
end
