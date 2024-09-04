class TeamPolicy < ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def new?
    user.is_manager?
  end

  def show?
    user.is_manager?
  end

  def create?
    user.is_manager?
  end

  def update?
    user.is_manager?
  end

  def edit?
    user.is_manager?
  end

  def destroy?
    false
  end
end