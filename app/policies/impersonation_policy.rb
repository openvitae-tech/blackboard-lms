# frozen_string_literal: true

class ImpersonationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def create?
    user.is_admin? && user.active_for_authentication?
  end

  def destroy?
    user.is_support?
  end
end
