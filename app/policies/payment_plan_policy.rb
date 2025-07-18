# frozen_string_literal: true

class PaymentPlanPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def new?
    user.is_admin? && record.payment_plan.blank?
  end

  def create?
    user.is_admin? && record.payment_plan.blank?
  end

  def show?
    user.is_admin? || user.is_owner? || user.is_support?
  end

  def edit?
    user.is_admin?
  end

  def update?
    user.is_admin?
  end
end
