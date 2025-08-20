# frozen_string_literal: true

class MobileNumber
  include ActiveModel::API

  attr_accessor :value, :country_code

  validates :value, numericality: true

  validate :validate_phone_number

  private

  def validate_phone_number
    case country_code
    when AVAILABLE_COUNTRIES[:india][:code]
      errors.add(:value, 'is not a valid Indian number') unless value.match?(/\A\d{10}\z/)
    when AVAILABLE_COUNTRIES[:uae][:code]
      errors.add(:value, 'is not a valid UAE number') unless value.match?(/\A\d{9}\z/)
    end
  end
end
