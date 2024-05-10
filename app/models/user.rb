require_relative "../services/application_service"

class User < ApplicationRecord
  include UserManagement

  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  validates :name, length: { minimum: 2, maximum: 255 }, allow_blank: true
  validates :role,
           inclusion: { in: USER_ROLES ,
                        message: "%{value} is not a valid user role" }

  belongs_to :learning_partner, optional: true

  belongs_to :manager, class_name: "User", optional: true
  has_many :learners, class_name: "User", foreign_key: "manager_id"

  def get_temp_password
    if self.temp_password_enc.present?
      Rails.application.message_verifier('temp_password').verify(self.temp_password_enc)
    end
  end

  def set_temp_password
    temp_password = SecureRandom.alphanumeric(8)
    self.password = self.password_confirmation = temp_password
    enc_password = Rails.application.message_verifier('temp_password').generate(temp_password)
    self.temp_password_enc = enc_password
  end
end
