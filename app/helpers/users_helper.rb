module UsersHelper
  def role_text(role)
    UserManagement::USER_ROLE_MAPPING[role.to_sym]
  end

  def user_role_mapping
    UserManagement::USER_ROLE_MAPPING.invert
  end

  def user_role_mapping_for_partner
    mapping= UserManagement::USER_ROLE_MAPPING.dup
    mapping.delete(:super_admin)
    mapping.invert
  end
end
