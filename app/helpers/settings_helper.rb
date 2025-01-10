module SettingsHelper
  def settings_list
    [
      {
        label: t("tags.label"),
        description: t("settings.description"),
        icon: "icon-filter",
        path: tags_path
    }
  ]
  end
end
