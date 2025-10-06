# frozen_string_literal: true

module ViewComponent
  module TextareaComponent
    TEXTAREA_SIZES = %w[md lg].freeze

    class Textarea
      TEXTAREA_SIZE_STYLE = {
        md: 'textarea-component-md main-text-lg-medium',
        lg: 'textarea-component-lg'
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

      def initialize(form:, field_name:, label:, placeholder:, value:, rows:, size:, html_options:, support_text:, error:, disabled:)
        @form = form
        @field_name = field_name
        @label = label
        @placeholder = placeholder
        @value = value
        @rows = 5
        @size = size
        @html_options = html_options
        @support_text = support_text
        @error = error
        @disabled = disabled

        html_options[:placeholder] = placeholder
        html_options[:class] = textarea_style
        html_options[:disabled] = true if disabled
        html_options[:rows] ||= rows
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
        base = ['textarea-component-label']
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

      errors = form&.object&.errors
      form_error = errors&.[](field_name)&.first
      final_error_message = error.presence || form_error
      has_error = final_error_message.present?

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
  end
end
