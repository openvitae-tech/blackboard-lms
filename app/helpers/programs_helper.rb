# frozen_string_literal: true

module ProgramsHelper
  def program_menu_items(program)
    [
      ViewComponent::MenuComponentHelper::MenuItem.new(
        label: t('button.edit'),
        url: edit_program_path(program),
        type: :link,
        options: { data: { turbo_frame: 'modal' } }
      ),
      ViewComponent::MenuComponentHelper::MenuItem.new(
        label: t('button.delete'),
        url: confirm_destroy_program_path(program),
        type: :link,
        extra_classes: 'text-danger',
        options: { data: { turbo_frame: 'modal' } }
      )
    ]
  end
end
