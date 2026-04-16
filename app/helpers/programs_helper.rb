# frozen_string_literal: true

module ProgramsHelper
  def program_menu_items(program, show_delete: true, learner_mode: false)
    items = []

    if learner_mode
      items << ViewComponent::MenuComponentHelper::MenuItem.new(
        label: t('programs.edit_details'),
        url: program_path(program, mode: Program::MANAGER_MODE),
        type: :link
      )
    else
      items << ViewComponent::MenuComponentHelper::MenuItem.new(
        label: t('button.edit'),
        url: edit_program_path(program, mode: params[:mode]),
        type: :link,
        options: { data: { turbo_frame: 'modal' } }
      )

      if show_delete
        items << ViewComponent::MenuComponentHelper::MenuItem.new(
          label: t('button.delete'),
          url: confirm_destroy_program_path(program, term: params[:term]),
          type: :link,
          extra_classes: 'text-danger',
          options: { data: { turbo_frame: 'modal' } }
        )
      end
    end

    items
  end
end
