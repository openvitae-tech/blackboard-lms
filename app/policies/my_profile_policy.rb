# frozen_string_literal: true

class MyProfilePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def show?
    !user.is_admin?
  end

  def share_certificate?
    !user.is_admin?
  end

  def generate_certificate?
    !user.is_admin?
  end

  def certificates?
    show?
  end

  def pending_certificates?
    show?
  end
end
