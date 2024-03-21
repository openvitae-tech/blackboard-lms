module UsersHelper
  def role_text(role)
    UserManagement::USER_ROLE_MAPPING[role.to_sym]
  end

  def user_role_mapping
    @user_role_mapping ||= UserManagement::USER_ROLE_MAPPING.invert
  end
end
