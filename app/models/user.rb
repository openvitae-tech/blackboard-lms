class User < ApplicationRecord

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

  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  validates :name, length: { minimum: 2, maximum: 255 }, allow_blank: true
  validates :role,
           inclusion: { in: USER_ROLES ,
                        message: "%{value} is not a valid user role" }

  belongs_to :learning_partner, optional: true

  belongs_to :manager, class_name: "User", optional: true
  has_many :learners, class_name: "User", foreign_key: "manager_id"

  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments

  def get_temp_password
    if self.temp_password_enc.present?
      Rails.application.message_verifier(password_verifier).verify(self.temp_password_enc)
    end
  end

  def set_temp_password
    temp_password = SecureRandom.alphanumeric(8)
    self.password = self.password_confirmation = temp_password
    enc_password = Rails.application.message_verifier(password_verifier).generate(temp_password)
    self.temp_password_enc = enc_password
  end

  def enrolled_for_course?(course)
    enrollments.exists?(course: course)
  end

  def password_verifier
    Rails.application.credentials.dig(:password_verifier)
  end
end
