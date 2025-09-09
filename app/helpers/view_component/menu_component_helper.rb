# frozen_string_literal: true

module ViewComponent
  module MenuComponentHelper
    MenuItem = Struct.new(
      :label,
      :url,
      :type,
      :options,
      :extra_classes,
      keyword_init: true
    )

    def menu_component(menu_items:, icon_class: '', label_hover: '', html_options: {})
      render(
        'view_components/menu_component/menu_component',
        menu_items: menu_items,
        icon_class:,
        label_hover:,
        html_options:
      )
    end
  end
end
