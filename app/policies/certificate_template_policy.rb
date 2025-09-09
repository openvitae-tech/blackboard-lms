# frozen_string_literal: true

class CertificateTemplatePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def new?
    user.is_admin?
  end

  def index?
    user.is_admin?
  end

  def create?
    user.is_admin?
  end

  def update?
    user.is_admin?
  end

  def confirm_destroy?
    user.is_admin?
  end

  def destroy?
    user.is_admin?
  end
end
