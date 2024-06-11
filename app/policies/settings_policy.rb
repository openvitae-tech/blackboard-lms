class SettingsPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def edit?
    user.present?
  end

  def update?
    user.present?
  end

  def update_password?
    user.present?
  end

  def team?
    user.present?
  end

  def invite_admin?
    user.is_admin?
  end
  def invite_member?
    user.is_admin? || user.is_owner? || user.is_manager?
  end

  def resend_invitation?
    record.confirmed_at.blank? && (user.is_admin? || user.is_owner? || user.is_manager?)
  end
end