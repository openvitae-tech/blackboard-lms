require_relative "../services/user_management/roles"

class User < ApplicationRecord
  include UserManagement

  validates :name, length: { minimum: 2, maximum: 255 }
  validates :role,
           inclusion: { in: USER_ROLES ,
                        message: "%{value} is not a valid user role" }
end
