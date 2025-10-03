# frozen_string_literal: true

module ViewComponent
  module TextareaComponent
    TEXTAREA_SIZES = %w[md lg].freeze

    def textarea_component(
      form: nil,
      field_name:,
      label:,
      placeholder:,
      value: nil,
      rows: 5,
      size: 'md',
      html_options: {},
      support_text: nil
    )
      raise "Incorrect textarea size: #{size}" unless TEXTAREA_SIZES.include?(size)

      error_message = form&.object&.errors&.[](field_name)&.first

      render partial: 'view_components/textarea_component/textarea', locals: {
        form:,
        field_name:,
        label:,
        value:,
        placeholder:,
        rows:,
        size:,
        html_options:,
        support_text: error_message.presence || support_text,
        error: error_message.present?
      }
    end
  end
end
