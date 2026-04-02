# frozen_string_literal: true

module ViewComponent
  module InputComponent
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

      def initialize(form:, name:, label:, type:, placeholder:, code_value:, value:, subtext:, error:,
                     icon_name:, icon_position:, disabled:, size:, html_options:)
        super(form:, name:, label:, type:, placeholder:, value:, subtext:, error:, icon_name:, icon_position:,
              disabled:, size:, html_options:)
        self.code_value = code_value
        self.code_name = name.present? ? "#{name}_code" : 'code'
      end

      def code_selectable?
        code_value.blank?
      end

      def error_style
        base = ['text-danger border-danger-dark',
                'group-focus-within:ring-danger-dark group-focus-within:border-danger-dark']
        base << 'group-focus-within:ring-1' unless code_selectable?
        base.join(' ')
      end

      def normal_style
        base = ['border-slate-grey-50 group-focus-within:border-primary']
        base << 'group-focus-within:ring-primary' if code_selectable?
        base.join(' ')
      end

      def code_wrapper_style
        base = ['mobile-code-base']
        color_style = if disabled
                        'border-disabled-color'
                      elsif error.present?
                        error_style
                      elsif code_selectable?
                        'border-slate-grey-50 group-focus:ring-primary group-focus:border-primary'
                      else
                        'border-slate-grey-50 group-focus-within:border-primary'
                      end

        size_style = INPUT_WRAPPER_STYLES[size.to_sym]
        code_width = code_selectable? ? CODE_SELECT_WIDTH[size.to_sym] : CODE_WIDTH[size.to_sym]
        code_text = CODE_TEXT[size.to_sym]
        [class_list(base, size_style, color_style), code_width, code_text].join(' ')
      end
    end
  end
end
