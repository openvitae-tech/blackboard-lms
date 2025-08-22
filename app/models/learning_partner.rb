# frozen_string_literal: true

class LearningPartner < ApplicationRecord
  include CustomValidations
  include PartnerState

  has_many :users, dependent: :destroy
  has_one :scorm, dependent: :destroy
  has_one :payment_plan, dependent: :destroy

  validates :name, presence: true, length: { in: 2..255 }
  validates :active_users_count, presence: true
  validates :supported_countries, presence: true
  validates :content, length: { maximum: 4096 }

  validate :acceptable_logo
  validate :acceptable_banner
  validate :supported_countries_must_be_valid
  validate :only_one_supported_country

  has_one_attached :logo
  has_one_attached :banner

  has_rich_text :content

  def parent_team
    @parent_team ||= Team.where(learning_partner_id: id, parent_team_id: nil).first
  end

  def update_active_users_count!
    users_count = users.where(state: %w[verified unverified
                                        active]).where.not(role: 'support').count
    self.active_users_count = users_count
    save!
  end

  private

  def supported_countries_must_be_valid
    return if supported_countries.blank?

    valid_values = AVAILABLE_COUNTRIES.values.pluck(:value)
    invalid = supported_countries - valid_values

    return unless invalid.any?

    errors.add(:supported_countries, "contains invalid counties: #{invalid.join(', ')}")
  end

  def only_one_supported_country
    return if supported_countries.blank?

    return unless supported_countries.size > 1

    errors.add(:supported_countries, 'can only have one country')
  end
end
