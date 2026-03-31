# frozen_string_literal: true

module NeoComponents
  module SampleMenuHelper
    def sample_menu_items
      [
        ViewComponent::MenuComponent::MenuItem.new(
          label: 'Edit',
          type: :link
        ),
        ViewComponent::MenuComponent::MenuItem.new(
          label: 'Change team',
          type: :link
        ),
        ViewComponent::MenuComponent::MenuItem.new(
          label: 'Delete',
          type: :link,
          extra_classes: 'text-danger'
        )
      ]
    end
  end
end
