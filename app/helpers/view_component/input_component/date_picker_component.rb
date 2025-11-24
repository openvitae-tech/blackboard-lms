# frozen_string_literal: true

module ViewComponent
  module InputComponent
    class DatePickerComponent
      include ViewComponent::ComponentHelper

      DATE_PICKER_SIZES = %w[md lg].freeze

      DATE_PICKER_SIZE_STYLE = {
        md: 'input-text-div-base-md main-text-md-normal',
        lg: 'input-text-div-base-lg main-text-lg-medium'
      }.freeze

      LABEL_STYLES = {
        md: 'input-text-label-md general-text-sm-normal',
        lg: 'input-text-label-lg general-text-md-normal'
      }.freeze

      SUPPORT_TEXT_STYLES = {
        md: 'input-text-subtext-md general-text-sm-normal',
        lg: 'input-text-subtext-lg general-text-md-normal'
      }.freeze

      ICON_SIZE = {
        md: 'input-text-icon-md',
        lg: 'input-text-icon-lg'
      }.freeze

      attr_accessor :form, :name, :label, :value, :size,
                    :support_text, :error, :disabled, :html_options

      def initialize(form:, name:, label:, value:, size:, support_text:, error:, disabled:, html_options:)
        raise "Incorrect date picker size: #{size}" unless DATE_PICKER_SIZES.include?(size)

        error_message = resolve_error(form, name, error)

        self.form = form
        self.name = name
        self.label = label
        self.value = value
        self.size = size
        self.support_text = (error_message.presence || support_text)
        self.error = error_message
        self.disabled = disabled
        self.html_options = html_options

        self.html_options[:disabled] = true if disabled
        self.html_options[:class] = date_picker_style
      end

      def date_picker_style
        base = ['w-full borde']
        size_style = DATE_PICKER_SIZE_STYLE[size.to_sym]

        color_style =
          if disabled
            'border-disabled-color text-disabled-color placeholder-disabled-color'
          elsif error.present?
            'text-danger focus:text-danger-dark border-danger focus:border-danger focus:ring-danger'
          else
            'text-letter-color-light border-slate-grey-50 focus:ring-primary'
          end

        class_list(base, size_style, color_style)
      end

      def label_style
        size_style = LABEL_STYLES[size.to_sym]

        color_style =
          if disabled
            'text-disabled-color'
          elsif error.present?
            'text-danger-dark'
          else
            'text-letter-color-light group-focus-within:text-primary'
          end

        class_list([], size_style, color_style)
      end

      def support_text_style
        size_style = SUPPORT_TEXT_STYLES[size.to_sym]

        color_style =
          if disabled
            'text-disabled-color'
          elsif error.present?
            'text-danger-dark'
          else
            'text-letter-color-light'
          end

        class_list([], size_style, color_style)
      end

      def icon_wrapper_style
        base = ['date-picker-icon-wrapper']

        disabled_style =
          if disabled
            'date-picker-icon-wrapper-disabled'
          else
            ''
          end

        class_list(base, disabled_style)
      end

      def icon_style
        size_style = ICON_SIZE[size.to_sym]

        color_style =
          if disabled
            'text-disabled-color'
          elsif error.present?
            'text-danger'
          else
            'text-letter-color-light'
          end
        class_list([], size_style, color_style)
      end
    end
  end
end
