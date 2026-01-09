# frozen_string_literal: true

module ViewComponent
  module InputComponent
    class InputTextComponent
      include ViewComponent::ComponentHelper

      INPUT_SIZE_STYLE = {
        md: 'input-text-md',
        lg: 'input-text-lg'
      }.freeze

      ICON_SIZE = {
        md: 'input-text-icon-md',
        lg: 'input-text-icon-lg'
      }.freeze

      INPUT_WRAPPER_STYLES = {
        md: 'input-text-div-base-md',
        lg: 'input-text-div-base-lg'
      }.freeze

      LABEL_STYLES = {
        md: 'input-text-label-md',
        lg: 'input-text-label-lg'
      }.freeze

      SUBTEXT_SIZE = {
        md: 'input-text-subtext-md',
        lg: 'input-text-subtext-lg'
      }.freeze

      attr_accessor :form, :name, :label, :type, :value, :subtext, :error, :icon_name, :icon_position, :disabled, :size,
                    :html_options

      def initialize(form:, name:, label:, type:, placeholder:, value:, subtext:, error:,
                     icon_name:, icon_position:, disabled:, size:, html_options:)
        error_message = resolve_error(form, name, error)

        self.form = form
        self.name = name
        self.label = label
        self.type = type
        self.value = value
        self.subtext = error_message.presence || subtext # Prioritise error over subtext
        self.error = error_message
        self.icon_name = icon_name
        self.icon_position = icon_position
        self.disabled = disabled
        self.size = size
        self.html_options = html_options
        self.html_options[:placeholder] = placeholder
        self.html_options[:class] = input_style
        self.html_options[:disabled] = disabled if disabled
      end

      def input_style
        base = ['input-text-base']
        color_style = if disabled
                        'text-disabled-color'
                      elsif error.present?
                        'text-danger focus:text-danger-dark'
                      else
                        'text-disabled-color focus:text-letter-color'
                      end

        size_style = INPUT_SIZE_STYLE[size.to_sym]
        class_list(base, size_style, color_style)
      end

      def placeholder
        html_options[:placeholder]
      end

      def placeholder=(value)
        html_options[:placeholder] = value
      end

      def input_wrapper_style
        base = ['input-text-div-base group']
        color_style = if disabled
                        'border-disabled-color'
                      elsif error.present?
                        'border-danger focus-within:border-danger-dark ring-danger-dark'
                      else
                        'border-slate-grey-50 focus-within:border-primary ring-primary'
                      end

        size_style = INPUT_WRAPPER_STYLES[size.to_sym]
        class_list(base, size_style, color_style)
      end

      def label_style
        base = []
        color_style = if disabled
                        'text-disabled-color'
                      elsif error.present?
                        'text-danger-dark'
                      else
                        'text-letter-color-light group-focus-within:text-primary'
                      end

        size_style = LABEL_STYLES[size.to_sym]
        class_list(base, size_style, color_style)
      end

      def icon_style
        base = ['input-text-icon-base']
        color_style = if disabled
                        'text-disabled-color'
                      elsif error.present?
                        'text-danger-dark'
                      else
                        'text-disabled-color group-focus-within:text-letter-color'
                      end
        class_list(base, '', color_style)
      end

      def icon_size
        ICON_SIZE[size.to_sym]
      end

      def subtext_style
        base = []
        color_style = if disabled
                        'text-disabled-color'
                      elsif error.present?
                        'text-danger-dark'
                      else
                        'text-letter-color-light'
                      end
        size_style = SUBTEXT_SIZE[size.to_sym]
        class_list(base, size_style, color_style)
      end
    end
  end
end
