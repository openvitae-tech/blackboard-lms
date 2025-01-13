module SettingsHelper
  def settings_list
    [
      {
        label: t("tags.label"),
        description: t("settings.description"),
        icon: "icon-tag",
        path: tags_path
    }
  ]
  end
end
