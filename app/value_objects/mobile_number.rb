# frozen_string_literal: true

class MobileNumber
  include ActiveModel::API

  attr_accessor :value, :country_code

  validates :value, numericality: true

  validate :validate_phone_number

  private

  def valid_phone?(phone, country)
    Phonelib.valid_for_country? phone, country
  end

  def validate_phone_number
    country = AVAILABLE_COUNTRIES.values.find { |country| country[:code] == country_code }

    if country.present?
      errors.add(:base, "Enter a valid phone number for #{country[:label]}") unless valid_phone?(value, country[:iso])
    else
      errors.add(:base, 'Unsupported country')
    end
  end
end
