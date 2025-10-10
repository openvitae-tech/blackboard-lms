# frozen_string_literal: true

module ViewComponent
  module TextareaComponent
    TEXTAREA_SIZES = %w[md lg].freeze

    class TextareaComponent
      include ViewComponent::ComponentHelper

      TEXTAREA_SIZE_STYLE = {
        md: 'textarea-component-md main-text-md-normal',
        lg: 'textarea-component-lg main-text-lg-medium'
      }.freeze

      LABEL_STYLES = {
        md: 'general-text-sm-normal',
        lg: 'general-text-md-normal'
      }.freeze

      SUPPORT_TEXT_STYLES = {
        md: 'general-text-sm-normal',
        lg: 'general-text-md-normal'
      }.freeze

      attr_accessor :form, :name, :label, :placeholder, :value,
                    :rows, :size, :support_text, :error, :disabled, :html_options

      def initialize(form:, name:, label:, placeholder:, value:, rows:, size:, support_text:,
                     error:, disabled:, html_options:)
        raise "Incorrect textarea size: #{size}" unless TEXTAREA_SIZES.include?(size)

        error_message = resolve_error(form, name, error)

        self.form = form
        self.name = name
        self.label = label
        self.placeholder = placeholder
        self.value = value
        self.rows = rows
        self.size = size
        self.support_text = (error_message.presence || support_text)
        self.error = error_message
        self.disabled = disabled
        self.html_options = html_options

        self.html_options[:placeholder] = placeholder
        self.html_options[:rows] ||= rows
        self.html_options[:disabled] = true if disabled
        self.html_options[:class] = textarea_style
      end

      def textarea_style
        base = ['textarea-component-base']
        size_style = TEXTAREA_SIZE_STYLE[size.to_sym]

        color_style =
          if disabled
            'textarea-disabled-state'
          elsif error.present?
            'textarea-error-state'
          else
            'textarea-active-state'
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
        base = ['textarea-support-text']
        size_style = SUPPORT_TEXT_STYLES[size.to_sym]

        color_style =
          if disabled
            'text-disabled-color'
          elsif error.present?
            'text-danger-dark'
          else
            'text-slate-grey-50'
          end

        class_list(base, size_style, color_style)
      end
    end

    def textarea_component(
      name:,
      placeholder:,
      form: nil,
      label: nil,
      value: nil,
      rows: 5,
      size: 'md',
      support_text: nil,
      error: nil,
      disabled: false,
      html_options: {}
    )
      textarea = TextareaComponent.new(
        form: form,
        name: name,
        label: label,
        placeholder: placeholder,
        value: value,
        rows: rows,
        size: size,
        support_text: support_text,
        error: error,
        disabled: disabled,
        html_options: html_options
      )

      render partial: 'view_components/textarea_component/textarea', locals: { textarea: }
    end
  end
end
