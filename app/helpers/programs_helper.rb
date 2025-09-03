# frozen_string_literal: true

module ProgramsHelper
  def program_menu_items(program)
    [
      MenuComponentHelper::MenuItem.new(
        label: I18n.t('button.edit'),
        url: edit_program_path(program),
        type: :link,
        options: { data: { turbo_frame: 'modal' } }
      ),
      MenuComponentHelper::MenuItem.new(
        label: I18n.t('button.delete'),
        url: confirm_destroy_program_path(program),
        type: :link,
        extra_classes: 'text-danger',
        options: { data: { turbo_frame: 'modal' } }
      )
    ]
  end
end
