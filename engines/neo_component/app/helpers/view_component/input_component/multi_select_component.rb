# frozen_string_literal: true

module ViewComponent
  module InputComponent
    class MultiSelectComponent
      include ViewComponent::ComponentHelper

      SIZES = %w[md lg].freeze

      TRIGGER_SIZE_STYLES = {
        md: 'min-h-10 px-3 py-2 main-text-md-normal',
        lg: 'min-h-12 px-4 py-3 main-text-lg-medium'
      }.freeze

      LABEL_STYLES = {
        md: 'input-text-label-md general-text-sm-normal',
        lg: 'input-text-label-lg general-text-md-normal'
      }.freeze

      SUPPORT_TEXT_STYLES = {
        md: 'input-text-subtext-md general-text-sm-normal',
        lg: 'input-text-subtext-lg general-text-md-normal'
      }.freeze

      attr_accessor :form, :name, :label, :options, :value, :size,
                    :support_text, :error, :disabled, :placeholder, :html_options

      def initialize(form:, name:, label:, options:, value:, size:, support_text:, error:,
                     disabled:, placeholder:, html_options:)
        raise "Incorrect multi_select size: #{size}" unless SIZES.include?(size)

        error_message = resolve_error(form, name, error)

        self.form = form
        self.name = name
        self.label = label
        self.options = options
        self.value = Array(value).map(&:to_s)
        self.size = size
        self.support_text = (error_message.presence || support_text)
        self.error = error_message
        self.disabled = disabled
        self.placeholder = placeholder
        self.html_options = html_options
        self.html_options[:class] = [
          'w-full flex flex-col gap-1',
          self.html_options[:class]
        ].compact.join(' ')
      end

      def trigger_style
        base = ['w-full flex items-center gap-2 rounded border cursor-pointer']
        size_style = TRIGGER_SIZE_STYLES[size.to_sym]

        color_style =
          if disabled
            'border-disabled-color cursor-not-allowed'
          elsif error.present?
            'border-danger'
          else
            'border-slate-grey-50'
          end

        class_list(base, size_style, color_style)
      end

      def label_style
        base = []
        size_style = LABEL_STYLES[size.to_sym]

        color_style =
          if disabled
            'text-disabled-color'
          elsif error.present?
            'text-danger-dark'
          else
            'text-letter-color-light group-focus-within:text-primary'
          end

        class_list(base, size_style, color_style)
      end

      def support_text_style
        base = []
        size_style = SUPPORT_TEXT_STYLES[size.to_sym]

        color_style =
          if disabled
            'text-disabled-color'
          elsif error.present?
            'text-danger-dark'
          else
            'text-letter-color-light'
          end

        class_list(base, size_style, color_style)
      end

      def input_name
        return "#{name}[]" unless form

        "#{form.object_name}[#{name}][]"
      end

      def selected?(option_value)
        value.include?(option_value.to_s)
      end
    end
  end
end
