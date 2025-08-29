# frozen_string_literal: true

module LoginsHelper
  def available_country_codes_list
    AVAILABLE_COUNTRIES.values.to_h { |c| [c[:code], c[:code]] }
  end
end
