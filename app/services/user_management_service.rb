# frozen_string_literal: true

class UserManagementService
  include Singleton

  def invite(email, role, team)
    user = User.new(email:, role:, team:, learning_partner_id: team.learning_partner_id)
    user.set_temp_password
    user
  end
end
