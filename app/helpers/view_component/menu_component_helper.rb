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

    MENU_POSITIONS = {
      left: 'menu-component-left',
      right: 'menu-component-right',
      center: 'menu-component-center'
    }.freeze

    def menu_component(menu_items:, position: 'right', html_options: {})
      position_key = position.to_s.downcase.to_sym
      position_class = MENU_POSITIONS[position_key] || MENU_POSITIONS[:right]

      menu_items_with_options = menu_items.map do |item|
        item.options ||= {}
        item.url = item.url.presence || 'javascript:void(0)'
        item
      end

      render(
        'view_components/menu_component/menu_component',
        menu_items: menu_items_with_options,
        position_class: position_class,
        html_options:
      )
    end
  end
end
