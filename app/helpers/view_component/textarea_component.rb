# frozen_string_literal: true

module ViewComponent
  module TextareaComponent
    TEXTAREA_SIZES = %w[md lg].freeze

    class Textarea
      TEXTAREA_SIZE_STYLE = {
        md: 'textarea-component-md main-text-base-normal',
        lg: 'textarea-component-lg main-text-lg-medium'
      }.freeze

      LABEL_STYLES = {
        md: 'general-text-sm-normal',
        lg: 'general-text-base-normal'
      }.freeze

      SUPPORT_TEXT_STYLES = {
        md: 'general-text-sm-normal',
        lg: 'general-text-base-normal'
      }.freeze

      attr_accessor :form, :field_name, :label, :placeholder, :value,
                    :rows, :size, :html_options, :support_text, :error, :disabled

      def initialize(form:, field_name:, label:, placeholder:, value:, rows:, size:, html_options:, support_text:,
                     error:, disabled:)
        self.form = form
        self.field_name = field_name
        self.label = label
        self.placeholder = placeholder
        self.value = value
        self.rows = rows
        self.size = size
        self.html_options = html_options
        self.support_text = support_text
        self.error = error
        self.disabled = disabled

        self.html_options[:placeholder] = placeholder
        self.html_options[:class] = textarea_style
        self.html_options[:disabled] = true if disabled
        self.html_options[:rows] ||= rows
      end

      def textarea_style
        base = ['textarea-component-base']
        size_style = TEXTAREA_SIZE_STYLE[size.to_sym]

        color_style =
          if disabled
            'border-disabled-color text-disabled-color placeholder-disabled-color'
          elsif error.present?
            'error-border error-text placeholder-danger-dark'
          else
            'text-letter-color-light placeholder-letter-color-light'
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
            'text-letter-color-light'
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

      private

      def class_list(base, size_style, color_style)
        base.append(size_style)
        base.append(color_style)
        base.join(' ')
      end
    end

    def textarea_component(
      field_name:,
      label:,
      placeholder:,
      form: nil,
      value: nil,
      rows: 5,
      size: 'md',
      html_options: {},
      support_text: nil,
      error: nil,
      disabled: false
    )
      raise "Incorrect textarea size: #{size}" unless TEXTAREA_SIZES.include?(size)

      final_error_message, has_error = resolve_error(form, field_name, error)

      textarea = Textarea.new(
        form: form,
        field_name: field_name,
        label: label,
        placeholder: placeholder,
        value: value,
        rows: rows,
        size: size,
        html_options: html_options,
        support_text: has_error ? final_error_message : support_text,
        error: has_error,
        disabled: disabled
      )

      render partial: 'view_components/textarea_component/textarea', locals: { textarea: textarea }
    end

    private

    def resolve_error(form, field_name, explicit_error)
      errors = form&.object&.errors
      form_error = errors&.[](field_name)&.first
      final_error_message = form_error.presence || explicit_error
      [final_error_message, final_error_message.present?]
    end
  end
end
