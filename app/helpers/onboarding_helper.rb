# frozen_string_literal: true

module OnboardingHelper
  def local_languages
    LocalContent::SUPPORTED_LANGUAGES.values.slice(0, 7)
  end

  def other_local_language(selected_language)
    local_languages.include?(selected_language) ? '' : selected_language
  end

  def show_selected_option(language)
    return false if current_user.preferred_local_language.blank?

    listed_language_selected = current_user.preferred_local_language == language
    return true if listed_language_selected

    (language == 'Other') && local_languages.exclude?(current_user.preferred_local_language)
  end

  def language_value(language)
    if language == 'Other'
      other_lang = other_local_language(current_user.preferred_local_language)
      other_lang.presence || 'Other'
    else
      language
    end
  end
end
