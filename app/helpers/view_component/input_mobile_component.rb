# frozen_string_literal: true

module ViewComponent
  module InputMobileComponent
    include ViewComponent::InputComponent
    class InputMobileComponent < InputTextComponent
      CODE_WIDTH = {
        md: 'w-16',
        lg: 'w-20'
      }.freeze

      CODE_SELECT_WIDTH = {
        md: 'w-20',
        lg: 'w-24'
      }.freeze

      CODE_TEXT = {
        md: 'mobile-code-md',
        lg: 'mobile-code-lg'
      }.freeze

      attr_accessor :form, :code_name, :name, :label, :type, :code_value, :value, :subtext, :error,
                    :icon_name, :icon_position, :disabled, :size, :html_options

      def initialize(form:, name:, label:, type:, placeholder:, code_value:, value:, subtext:, error:, icon_name:, icon_position:,
                     disabled:, size:, html_options:)
        super(form:, name:, label:, type:, placeholder:, value:, subtext:, error:, icon_name:, icon_position:,
              disabled:, size:, html_options:)
        self.code_value = code_value
        self.code_name = name.present? ? "#{name}_code" : 'code'
      end

      def code_selectable?
        code_value.blank?
      end

      def code_wrapper_style
        base = ['mobile-code-base']
        color_style = if disabled
                        'border-disabled-color'
                      elsif error.present?
                        'border-danger focus-within:ring-danger-dark'
                      elsif code_selectable?
                        'border-slate-grey-50 focus-within:ring-primary'
                      else
                        'border-slate-grey-50'
                      end

        size_style = INPUT_WRAPPER_STYLES[size.to_sym]
        code_width = code_selectable? ? CODE_SELECT_WIDTH[size.to_sym] : CODE_WIDTH[size.to_sym]
        code_text = CODE_TEXT[size.to_sym]
        [class_list(base, size_style, color_style), code_width, code_text].join(' ')
      end
    end

    def input_mobile_component(
      form: nil,
      name: nil,
      label: nil,
      placeholder: 'Enter your mobile number',
      country_code: '',
      value: '',
      subtext: nil,
      error: nil,
      icon_name: nil,
      icon_position: 'right',
      disabled: false,
      size: 'md',
      html_options: {}
    )
      input = InputMobileComponent.new(
        form:, name:, label:, type: 'number', placeholder:, code_value: country_code, value:, subtext:, error:,
        icon_name:, icon_position:, disabled:, size:, html_options:
      )

      render partial: 'view_components/inputs/input_mobile_component',
             locals: { input: }
    end
  end
end
