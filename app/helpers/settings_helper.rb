module SettingsHelper
  def settings_list
    [
      {
        label: t("tags.label"),
        description: t("settings.description"),
        icon: "icon-tag",
        path: tags_path,
        is_visible: current_user.is_admin?
      },
      {
        label: t("components.title"),
        description: t("components.label"),
        icon: "icon-list",
        path: ui_components_path,
        is_visible: current_user.is_admin?
      },
      {
        label: "Invoice",
        description: t("components.label"),
        icon: "icon-list",
        path: invoices_path,
        is_visible: current_user.is_owner?
      }
    ]
  end
end
