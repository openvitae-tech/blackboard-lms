# frozen_string_literal: true

module ViewComponent
  module InputTextareaComponent
    def input_textarea_component(form: nil, field_name: nil, label: nil,
                                 placeholder: nil, value: nil, rows: 5, html_options: {})
      render partial: 'view_components/inputs/text_area', locals: {
        form:,
        field_name:,
        label:,
        placeholder:,
        value:,
        rows:,
        html_options:
      }
    end
  end
end
