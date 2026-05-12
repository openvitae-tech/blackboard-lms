# frozen_string_literal: true

class DashboardPolicy
  attr_reader :user, :record

  def initialize(user, _record)
    @user = user
    @record = record
  end

  def index?
    user.privileged_user?
  end

  def nudge_all?
    user.privileged_user?
  end

  def nudge_user?
    user.privileged_user?
  end

  def team_progress?
    index?
  end

  def team_member_profile?
    index?
  end

  def started_vs_completed?
    index?
  end

  def recent_activity?
    index?
  end

  def appreciate_member?
    index?
  end
end
