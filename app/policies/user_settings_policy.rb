# frozen_string_literal: true

class UserSettingsPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def show?
    user.present?
  end

  def edit?
    user.present?
  end

  def update?
    user.present?
  end

  def change_password?
    user.present?
  end

  def update_password?
    user.present?
  end

  def team?
    user.present?
  end

  def edit_profile_picture?
    user.present?
  end

  def update_profile_picture?
    user.present?
  end

  def confirm_logout?
    user.present?
  end

  def edit_email?
    user.present?
  end

  def update_email?
    user.present?
  end

  def edit_phone_number?
    user.present?
  end

  def update_phone_number?
    user.present?
  end

  def verify_phone_number?
    user.present?
  end

  def send_verification_email?
    user.present?
  end
end
