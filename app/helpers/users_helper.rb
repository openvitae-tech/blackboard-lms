module UsersHelper
  def role_text(role)
    User::USER_ROLE_MAPPING[role.to_sym]
  end

  def user_role_mapping
    User::USER_ROLE_MAPPING.invert
  end

  def user_role_mapping_for_partner
    mapping= User::USER_ROLE_MAPPING.dup
    mapping.delete(:admin)
    mapping.invert
  end
end
