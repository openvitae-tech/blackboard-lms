# frozen_string_literal: true

class EventPolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, _record)
    @user = user
    @record = record
  end

  def index?
    user.is_admin?
  end
end
