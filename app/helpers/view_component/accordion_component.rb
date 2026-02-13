# frozen_string_literal: true

module ViewComponent
  module AccordionComponent
    def accordion_component(title:, icon_position: 'right', &)
      content = capture(&)
      icon_position_style = icon_position == 'right' ? 'justify-between' : 'flex-row-reverse justify-end gap-2'
      render partial: 'view_components/accordion_component/accordion',
             locals: { title:, content:, icon_position_style: }
    end
  end
end
