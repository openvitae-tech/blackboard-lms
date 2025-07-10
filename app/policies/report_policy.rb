# frozen_string_literal: true

class ReportPolicy
  attr_reader :user, :report

  def initialize(user, report)
    @user = user
    @report = report
  end

  def new?
    user.privileged_user?
  end

  def create?
    user.privileged_user?
  end

  def download?
    user.privileged_user?
  end
end
