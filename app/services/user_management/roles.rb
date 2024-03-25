module UserManagement

  USER_ROLE_MAPPING  = {
    platform_admin: "Platform Admin",
    partner_admin: "Admin",
    learner: "Learner"
  }

  USER_ROLES = USER_ROLE_MAPPING.keys.map(&:to_s)

  def is_platform_admin?
    self.role == "platform_admin"
  end

  def is_partner_admin?
    self.role == "partner_admin"
  end

  def is_learner?
    self.role == "learner"
  end
end