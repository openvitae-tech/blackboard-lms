# frozen_string_literal: true

module MenuComponentHelper
  MenuItem = Struct.new(
    :label,
    :url,
    :type,
    :options,
    :extra_classes,
    :visible,
    keyword_init: true
  ) do
    def visible?
      visible != false
    end
  end

  def menu_component(menu_items, icon_class: '', label_hover: '', html_options: {})
    render(
      'ui/inputs/menu_component',
      menu_items: menu_items.select(&:visible?),
      icon_class:,
      label_hover:,
      html_options:
    )
  end
end
