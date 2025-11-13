# frozen_string_literal: true

module ViewComponent
  module MenuComponentHelper
    MenuItem = ViewComponent::MenuItem

    def menu_component_old(menu_items:, icon_class: '', html_options: {})
      menu_items_with_options = menu_items.map do |item|
        item.options ||= {}
        item.url = item.url.presence || '#'
        item
      end

      render(
        'view_components/menu_component_old/menu_component',
        menu_items: menu_items_with_options,
        icon_class:,
        html_options:
      )
    end
  end
end
