# frozen_string_literal: true

module SettingsHelper
  def settings_list
    [
      {
        label: t('tags.label'),
        description: t('settings.description'),
        icon: 'icon-tag',
        path: tags_path
      },
      {
        label: t('components.title'),
        description: t('components.label'),
        icon: 'icon-list',
        path: ui_components_path
      }
    ]
  end
end
