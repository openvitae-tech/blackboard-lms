require_relative "../services/application_service"

class User < ApplicationRecord
  include UserManagement

  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  validates :name, length: { minimum: 2, maximum: 255 }
  validates :role,
           inclusion: { in: USER_ROLES ,
                        message: "%{value} is not a valid user role" }

  belongs_to :learning_partner, optional: true


  def get_temp_password
    Rails.application.message_verifier('temp_password').verify(self.temp_password_enc)
  end

  def set_temp_password
    temp_password = SecureRandom.alphanumeric(8)
    self.password = self.password_confirmation = temp_password
    enc_password = Rails.application.message_verifier('temp_password').generate(temp_password)
    self.temp_password_enc = enc_password
  end
end
