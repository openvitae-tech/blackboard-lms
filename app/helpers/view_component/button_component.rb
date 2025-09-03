# frozen_string_literal: true

module ViewComponent
  module ButtonComponent
    def button(label: nil, type: 'primary', size: 'md', icon_name: nil, icon_position: 'left', tooltip_text: '',
               tooltip_position: 'bottom', disabled: false, html_options: {})
      ApplicationController.renderer.render(
        partial: "view_components/buttons/#{type}",
        locals: {
          label:,
          type:,
          size:,
          icon_name:,
          icon_position:,
          tooltip_text:,
          tooltip_position:,
          disabled:,
          html_options:
        }
      )
    end
  end
end
