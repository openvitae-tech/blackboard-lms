require_relative "../services/application_service"

class User < ApplicationRecord
  include UserManagement

  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  validates :name, length: { minimum: 2, maximum: 255 }
  validates :role,
           inclusion: { in: USER_ROLES ,
                        message: "%{value} is not a valid user role" }
end
