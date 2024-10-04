# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, _record)
    @user = user
    @record = record
  end

  def index?
    user && (user.is_manager? || user.is_owner?)
  end
end
