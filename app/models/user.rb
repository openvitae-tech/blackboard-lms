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
  validates :phone, numericality: true, length: { minimum: 10, maximum: 10 }, allow_blank: true

  belongs_to :learning_partner, optional: true

  # This is a self referential relationship, learner and his manager are mapped to same User model.
  belongs_to :manager, class_name: "User", optional: true
  has_many :learners, class_name: "User", foreign_key: "manager_id"

  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments
  has_many :notifications, dependent: :destroy

  belongs_to :team

  def set_temp_password
    temp_password = SecureRandom.alphanumeric(8)
    self.password = self.password_confirmation = temp_password
    enc_password = Rails.application.message_verifier(password_verifier).generate(temp_password)
    self.temp_password_enc = enc_password
  end

  def get_temp_password
    if self.temp_password_enc.present?
      Rails.application.message_verifier(password_verifier).verify(self.temp_password_enc)
    end
  end

  def enrolled_for_course?(course)
    enrollments.exists?(course: course)
  end

  def get_enrollment_for(course)
    enrollments.where(course: course).first
  end

  def verified?
    confirmed_at.present?
  end

  def set_otp!
    if otp_generated_at && otp_generated_at < 5.minutes.ago
      otp = rand(1000..9999)
      Rails.logger.info "New OTP for #{phone} is #{otp}"

      update(otp: otp, otp_generated_at: DateTime.now)
    end
  end

  private
  def password_verifier
    Rails.application.credentials.dig(:password_verifier)
  end
end
