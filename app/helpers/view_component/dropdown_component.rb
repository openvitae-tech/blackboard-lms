# frozen_string_literal: true

module ViewComponent
  module DropdownComponent
    DROPDOWN_SIZES = %w[md lg].freeze

    class DropdownComponent
      include ViewComponent::ComponentHelper

      DROPDOWN_SIZE_STYLE = {
        md: 'dropdown-component-md main-text-md-normal',
        lg: 'dropdown-component-lg main-text-lg-medium'
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
                    :support_text, :error, :disabled, :html_options, :placeholder

      def initialize(form:, name:, label:, options:, value:, size:, support_text:, error:, disabled:, html_options:, placeholder:)
        raise "Incorrect dropdown size: #{size}" unless DROPDOWN_SIZES.include?(size)

        error_message = resolve_error(form, name, error)

        self.form = form
        self.name = name
        self.label = label
        self.options = options
        self.value = value
        self.size = size
        self.support_text = (error_message.presence || support_text)
        self.error = error_message
        self.disabled = disabled
        self.html_options = html_options
        self.placeholder = placeholder

        self.html_options[:disabled] = true if disabled
        self.html_options[:class] = dropdown_style
      end

      def select_options
         if placeholder.present?
           [[placeholder, ""]] + options
         else
           options
         end
      end


      def dropdown_style
        base = ['dropdown-component-base']
        size_style = DROPDOWN_SIZE_STYLE[size.to_sym]

        color_style =
          if disabled
            'text-disabled-color'
          elsif error.present?
            'text-danger focus:text-danger-dark border-danger focus:border-danger focus:ring-danger'
          else
            'text-letter-color-light border-slate-grey-50 focus:ring-primary'
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
    end

    def dropdown_component(
      form: nil,
      name: nil,
      label: nil,
      options: [],
      value: nil,
      size: 'md',
      support_text: nil,
      error: nil,
      disabled: false,
      html_options: {},
      placeholder: nil
    )
      dropdown = DropdownComponent.new(
        form:,
        name:,
        label:,
        options:,
        value:,
        size:,
        support_text:,
        error:,
        disabled:,
        html_options:,
        placeholder:
      )

      render partial: 'view_components/dropdown_component/dropdown',
             locals: { dropdown: }
    end
  end
end
