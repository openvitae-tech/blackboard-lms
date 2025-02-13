# frozen_string_literal: true

module OnboardingHelper

  def local_languages
    LocalContent::SUPPORTED_LANGUAGES.values.slice(0, 7)
  end

  def other_local_language(selected_language)
    local_languages.include?(selected_language) ? "" : selected_language
  end
end