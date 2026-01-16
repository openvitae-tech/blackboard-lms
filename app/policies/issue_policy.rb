# frozen_string_literal: true

class IssuePolicy
  attr_reader :user, :issue

  def initialize(user, record)
    @user = user
    @issue = record
  end

  def new?
    user == @issue.user
  end

  def create?
    user == @issue.user
  end
end
