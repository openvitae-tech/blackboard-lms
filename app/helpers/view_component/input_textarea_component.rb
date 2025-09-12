# frozen_string_literal: true

module ViewComponent
  module InputTextareaComponent
    def input_textarea_component(
      form:,
      field_name:,
      label:,
      placeholder:,
      value: nil,
      rows: 5,
      html_options: {}
    )
      html_options = html_options.merge(
        placeholder: placeholder,
        rows: rows
      )

      render partial: 'view_components/inputs/textarea', locals: {
        form:,
        field_name:,
        label:,
        value:,
        html_options:
      }
    end
  end
end
