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
end
