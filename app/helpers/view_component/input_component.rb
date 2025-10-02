# frozen_string_literal: true

module ViewComponent
  module InputComponent
    def input_field(form: nil, field_name: nil, label: nil,
                    placeholder: nil, width: 'w-56', height: nil, left_icon: nil, right_icon: nil, type: 'text',
                    options: [], value: nil, rows: '5', option: nil, html_options: {})
      partial_path = 'view_components/inputs/text_field' unless lookup_context.exists?(partial_path, [], true)

      html_options[:data] ||= {}

      render partial: partial_path, locals: {
        form:,
        field_name:,
        label:,
        placeholder:,
        width:,
        height:,
        left_icon:,
        right_icon:,
        type:,
        options:,
        value:,
        rows:,
        option:,
        html_options:
      }
    end

    def input_radio(form: nil, field_name: nil, label: nil,
                    placeholder: 'Enter text', width: 'w-56', height: nil,
                    value: nil, option: nil, html_options: {})
      render partial: 'view_components/inputs/radio_field', locals: {
        form:,
        field_name:,
        label:,
        placeholder:,
        width:,
        height:,
        value:,
        option:,
        html_options:
      }
    end

    def input_dropdown(form: nil, field_name: nil, label: nil,
                       width: 'w-56', height: nil, placeholder: nil,
                       options: [], value: nil, html_options: {})
      render partial: 'view_components/inputs/dropdown_field', locals: {
        form:,
        field_name:,
        label:,
        width:,
        height:,
        placeholder:,
        options:,
        value:,
        html_options:
      }
    end

    def input_checkbox(form: nil, field_name: nil, label: nil, width: 'w-56',
                       value: nil, allow_multiple: false)
      render partial: 'view_components/inputs/checkbox_field', locals: {
        form:,
        field_name:,
        label:,
        width:,
        value:,
        allow_multiple:
      }
    end

    def input_mobile(form:, field_name:, placeholder: 'Enter 10-digit mobile number',
                     value: nil, label: nil, flag: nil, html_options: {})
      value ||= form.object.public_send(field_name) if form.object.respond_to?(field_name)

      render partial: 'view_components/inputs/mobile_field', locals: {
        form:,
        field_name:,
        placeholder:,
        value:,
        label:,
        flag:,
        html_options:
      }
    end

    def input_otp(form:, field_prefix: 'otp', count: 4, input_options: {}, wrapper_options: {})
      content_tag(:div, class: 'flex justify-between gap-6 w-full', **(wrapper_options || {}).except(:data)) do
        safe_join(
          count.times.map do |i|
            field_name = "#{field_prefix}_#{number_to_human(i + 1)}"

            input_field(
              form:,
              field_name:,
              type: 'text',
              width: 'min-w-16',
              html_options: {
                class: 'input-text-otp',
                maxlength: 1,
                inputmode: 'numeric',
                pattern: '[0-9]*'
              }.merge(input_options)
            )
          end
        )
      end
    end

    # form component date_select_component
    # @param min minimum date
    # @param maximum date
    def date_select_component(form:, field_name:, min: nil, max: nil, placeholder: 'YYYY-MM-DD')
      render partial: 'view_components/inputs/date_select_component',
             locals: { form:, field_name:, min:, max:, placeholder: }
    end

    class InputTextComponent
      INPUT_SIZE_STYLE = {
        md: 'input-text-md',
        lg: 'input-text-lg'
      }.freeze

      ICON_SIZE = {
        md: 'input-text-icon-md',
        lg: 'input-text-icon-lg'
      }.freeze

      INPUT_DIV_STYLES = {
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

      attr_accessor :form, :name, :label, :value, :subtext, :error, :icon_name, :icon_position, :disabled, :size,
                    :html_options

      def initialize(form:, name:, label:, placeholder:, value:, subtext:, error:, icon_name:, icon_position:,
                     disabled:, size:, html_options:)
        self.form = form
        self.name = name
        self.label = label
        self.value = value
        self.subtext = error || subtext # Prioritise error over subtext
        self.error = error
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

      def input_div_style
        base = ['input-text-div-base']
        color_style = if disabled
                        'border-disabled-color'
                      elsif error.present?
                        'border-danger focus-within:border-danger-dark'
                      else
                        'border-slate-grey-50 focus-within:border-primary'
                      end

        size_style = INPUT_DIV_STYLES[size.to_sym]
        class_list(base, size_style, color_style)
      end

      def label_style
        base = []
        color_style = if disabled
                        'text-disabled-color'
                      elsif error.present?
                        'text-danger-dark'
                      else
                        'text-letter-color-light'
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
                        'text-letter-color-light'
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

      private

      def class_list(base, size_style, color_style)
        base.append(size_style)
        base.append(color_style)
        base.join(' ')
      end
    end

    def input_with_icon(icon, input_tag, position)
      ordered = position == 'left' ? [icon, input_tag] : [input_tag, icon]
      safe_join(ordered.compact)
    end

    def input_text_component(
      form: nil,
      name: nil,
      label: nil,
      placeholder: 'Placeholder',
      value: '',
      subtext: nil,
      error: nil,
      icon_name: nil,
      icon_position: 'right',
      disabled: false,
      size: 'md',
      html_options: {}
    )
      input = InputTextComponent.new(
        form:, name:, label:, placeholder:, value:, subtext:, error:, icon_name:, icon_position:, disabled:, size:,
        html_options:
      )

      render partial: 'view_components/inputs/input_text_component',
             locals: { input: }
    end
  end
end
