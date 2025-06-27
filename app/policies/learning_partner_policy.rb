# frozen_string_literal: true

class LearningPartnerPolicy
  attr_reader :user, :learning_partner

  def initialize(user, learning_partner)
    @user = user
    @learning_partner = learning_partner
  end

  def index?
    user.is_admin?
  end

  def show?
    user.is_admin?
  end

  def create?
    user.is_admin?
  end

  def new?
    user.is_admin?
  end

  def update?
    user.is_admin?
  end

  def edit?
    user.is_admin?
  end

  def destroy?
    false
  end

  def invite?
    learning_partner.active_users_count < learning_partner.payment_plan.total_seats
  end

  def activate?
    user.is_admin? && learning_partner.deactivated?
  end

  def deactivate?
    user.is_admin? && learning_partner.active?
  end
end
