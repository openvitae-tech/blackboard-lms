# frozen_string_literal: true

class User < ApplicationRecord
  include UserState
  include CustomValidations

  scope :active, -> { where(state: 'active') }
  scope :skip_deactivated, -> { where.not(state: 'in-active') }

  EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  PHONE_REGEXP = /\A[6-9][0-9]{9}\z/
  COMMUNICATION_CHANNELS = %w[sms whatsapp].freeze

  TEST_OTP = 1212

  PER_PAGE_LIMIT = 5

  ADMIN = 'admin'
  OWNER = 'owner'
  MANAGER = 'manager'
  LEARNER = 'learner'
  SUPPORT = 'support'

  USER_ROLE_MAPPING = {
    ADMIN => 'Admin',
    OWNER => 'Owner',
    MANAGER => 'Manager',
    LEARNER => 'Learner',
    SUPPORT => 'Support'
  }.symbolize_keys.freeze

  USER_ROLES = [ADMIN, OWNER, MANAGER, LEARNER, SUPPORT].freeze
  GENDERS = ['Male', 'Female', 'Other', 'Prefer not to say'].freeze

  # add dynamic methods using meta programming for checking the current role
  # of a user.
  USER_ROLES.each do |role|
    define_method "is_#{role}?" do
      self.role == role
    end
  end

  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  validates :name, presence: true, length: { minimum: 2, maximum: 64 }

  validates :role,
            inclusion: { in: USER_ROLES,
                         message: I18n.t('user.invalid_role') }
  validates :phone, numericality: true, allow_nil: true, uniqueness: true
  validates :state, inclusion: { in: USER_STATES, message: I18n.t('user.invalid_state') }

  validate :dob_within_valid_age_range
  validate :communication_channels_are_valid
  validates :gender,
            inclusion: { in: GENDERS,
                         message: I18n.t('user.invalid_gender') }, allow_blank: true

  validate :validate_phone_number

  belongs_to :learning_partner, optional: true, counter_cache: true

  after_create :update_active_users_count
  after_update :update_active_users_count, if: :saved_change_to_state?

  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments
  has_many :program_users, dependent: :destroy
  has_many :programs, through: :program_users
  has_many :course_certificates, dependent: :destroy

  belongs_to :team, optional: true

  has_many :reports,
           class_name: 'Report',
           foreign_key: :generated_by,
           inverse_of: :generator,
           dependent: :nullify

  def set_temp_password
    temp_password = SecureRandom.alphanumeric(8)
    self.password = self.password_confirmation = temp_password
    enc_password = Rails.application.message_verifier(password_verifier).generate(temp_password)
    self.temp_password_enc = enc_password
  end

  def temp_password
    return if temp_password_enc.blank?

    Rails.application.message_verifier(password_verifier).verify(temp_password_enc)
  end

  def enrolled_for_course?(course)
    enrollments.exists?(course:)
  end

  def get_enrollment_for(course)
    enrollments.find_by(course:)
  end

  def privileged_user?
    is_manager? || is_owner? || is_support?
  end

  def set_otp!
    return if otp_generated_at.present? && otp_generated_at >= 5.minutes.ago && otp.present?

    otp = Rails.env.production? ? rand(1000..9999) : TEST_OTP
    encrypt = Rails.application.message_verifier(password_verifier).generate(otp)
    update!(otp: encrypt, otp_generated_at: DateTime.now)
  end

  def clear_otp!
    update!(otp: nil)
  end

  def not_admin?
    !is_admin?
  end

  def reset_confirmation_token
    generate_confirmation_token!
  end

  # overridden methods for Devise specific actions
  def send_devise_notification(notification, *)
    devise_mailer.send(notification, self, *).deliver_later
  end

  def send_reset_password_instructions
    if deactivated? || unverified?
      errors.add(:base, inactive_message)
      return false
    end

    super
  end

  def active_for_authentication?
    active_or_verified_user = active? || verified?

    if is_admin?
      active_or_verified_user
    else
      learning_partner.active? && active_or_verified_user
    end
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

  def manager_of?(other_user)
    return false unless other_user.learning_partner_id == learning_partner_id

    is_owner? || is_support? || other_user.team.ancestors.include?(team)
  end

  def send_confirmation_notification?
    email.present?
  end

  def email_required?
    false
  end

  def phone_verified?
    user.phone_confirmed_at.present?
  end

  private

  def password_verifier
    Rails.application.credentials[:password_verifier]
  end

  def update_active_users_count
    return if learning_partner.nil? || is_support?

    learning_partner.update_active_users_count!
  end

  def communication_channels_are_valid
    invalid = communication_channels - COMMUNICATION_CHANNELS
    errors.add(:communication_channels, "contains invalid channels: #{invalid.join(', ')}") if invalid.any?
  end

  def validate_phone_number
    return if phone.blank?

    case country_code
    when AVAILABLE_COUNTRIES[:india][:code]
      errors.add(:phone, 'must be a valid Indian number') unless phone.match?(/\A\d{10}\z/)
    when AVAILABLE_COUNTRIES[:uae][:code]
      errors.add(:phone, 'must be a valid UAE number') unless phone.match?(/\A\d{9}\z/)
    else
      errors.add(:base, 'Unsupported country')
    end
  end
end
