# frozen_string_literal: true

module ViewComponent
  module AccordionComponent
    def accordion_component(
      header:,
      icon_position: 'right',
      open: false,
      wrapper_class: 'cursor-pointer hover:bg-primary-light-50',
      content_class: '',
      icon_class: '',
      &
    )
      content = capture(&)
      icon_position_style = icon_position == 'right' ? 'justify-between' : 'flex-row-reverse justify-end gap-2'
      render partial: 'view_components/accordion_component/accordion',
             locals: { header:, content:, icon_position_style:, open:, wrapper_class:, content_class:, icon_class: }
    end
  end
end
