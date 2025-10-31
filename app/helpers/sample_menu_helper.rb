# frozen_string_literal: true

module SampleMenuHelper
  def sample_menu_items
    [
      ViewComponent::MenuComponentHelper::MenuItem.new(
        label: t('button.edit'),
        type: :link
      ),
      ViewComponent::MenuComponentHelper::MenuItem.new(
        label: 'Change team',
        type: :link
      ),
      ViewComponent::MenuComponentHelper::MenuItem.new(
        label: t('button.delete'),
        type: :link,
        extra_classes: 'text-danger'
      )
    ]
  end
end
