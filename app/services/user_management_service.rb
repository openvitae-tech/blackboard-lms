# frozen_string_literal: true

class UserManagementService
  include Singleton

  def invite(email, role, partner)
    user = User.new(email:, role:, learning_partner: partner)
    user.set_temp_password
    user
  end
end
