module UserManagement

  USER_ROLE_MAPPING  = {
    admin: "Admin",
    owner: "Owner",
    manager: "Manager",
    learner: "Learner"
  }

  USER_ROLES = USER_ROLE_MAPPING.keys.map(&:to_s)

  # add dynamic methods using meta programming for checking the current role
  # of a user.
  USER_ROLES.each do |role|
    define_method "is_#{role}?" do
      self.role == role
    end
  end
end