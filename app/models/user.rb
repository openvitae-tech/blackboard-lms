# frozen_string_literal: true

class User < ApplicationRecord

  include UserState
  include CustomValidations


  EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  TEST_OTP = 1212

  USER_ROLE_MAPPING = {
    admin: 'Admin',
    owner: 'Owner',
    manager: 'Manager',
    learner: 'Learner'
  }.freeze

  USER_ROLES = USER_ROLE_MAPPING.keys.map(&:to_s)

  # add dynamic methods using meta programming for checking the current role
  # of a user.
  USER_ROLES.each do |role|
    define_method "is_#{role}?" do
      self.role == role
    end
  end

  GENDERS = %w[Male Female Other]

  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  validates :name, presence: true, length: { minimum: 2, maximum: 64 }
  validates :role,
            inclusion: { in: USER_ROLES,
                         message: '%<value>s is not a valid user role' }
  validates :phone, numericality: true, length: { minimum: 10, maximum: 10 }, allow_blank: true
  validates :state, inclusion: { in: USER_STATES, message: '%<value>s is not a valid user state' }
  validate :dob_within_valid_age_range
  validates :gender,
            inclusion: { in: GENDERS,
                         message: '%<value>s is not a valid gender' }, allow_blank: true


  has_secure_password :otp, validations: false

  belongs_to :learning_partner, optional: true, counter_cache: true

  # This is a self referential relationship, learner and his manager are mapped to same User model.
  belongs_to :manager, class_name: 'User', optional: true
  has_many :learners, class_name: 'User', foreign_key: 'manager_id'

  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments

  belongs_to :team, optional: true

  scope :skip_deactivated, -> { where.not(state: 'in-active') }

  def set_temp_password
    temp_password = SecureRandom.alphanumeric(8)
    self.password = self.password_confirmation = temp_password
    enc_password = Rails.application.message_verifier(password_verifier).generate(temp_password)
    self.temp_password_enc = enc_password
  end

  def get_temp_password
    return unless temp_password_enc.present?

    Rails.application.message_verifier(password_verifier).verify(temp_password_enc)
  end

  def enrolled_for_course?(course)
    enrollments.exists?(course:)
  end

  def get_enrollment_for(course)
    enrollments.find_by(course: course)
  end

  def set_otp!
    return unless otp_generated_at.blank? || otp_generated_at < 5.minutes.ago

    otp = Rails.env.production? ? rand(1000..9999) : TEST_OTP
    update!(otp: otp.to_s, otp_generated_at: DateTime.now)
  end

  def not_admin?
    !is_admin?
  end

  # overridden methods for Devise specific actions
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def send_reset_password_instructions
    if deactivated? || unverified?
      errors.add(:base, inactive_message)
      return false
    end

    super
  end

  def active_for_authentication?
    super && (self.active? || self.verified?)
  end

  def inactive_message
    I18n.t('user.deactivated_account')
  end

  def display_name
    name.downcase.split.first&.capitalize
  end

  def score
    @score ||= enrollments.map(&:score).reduce(:+) || 0
  end

  def active_learner?
    active? && is_learner?
  end
  def is_manager_of?(other_user)
    return false unless other_user.learning_partner_id == self.learning_partner_id
    is_owner? || other_user.team.ancestors.include?(self.team)
  end

  private

  def password_verifier
    Rails.application.credentials[:password_verifier]
  end
end
