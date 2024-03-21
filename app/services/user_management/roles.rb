module UserManagement

  USER_ROLE_MAPPING  = {
    platform_admin: "Platform Admin",
    partner_admin: "Admin",
    learner: "Learner"
  }

  USER_ROLES = USER_ROLE_MAPPING.keys.map(&:to_s)
end