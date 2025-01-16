# frozen_string_literal: true

class SettingPolicy
  attr_reader :user

  def initialize(user, record)
    @user = user
    @setting = record
  end

  def index?
    user.is_admin?
  end
end
