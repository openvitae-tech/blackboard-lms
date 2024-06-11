class UserManagementService
  include Singleton

  def invite(email, role, partner)
    user = User.new(email: email, role: role, learning_partner: partner)
    user.set_temp_password
    user
  end
end