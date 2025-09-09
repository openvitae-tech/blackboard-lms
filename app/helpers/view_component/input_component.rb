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

    def input_text_area(form: nil, field_name: nil, label: nil,
                        placeholder: nil, width: 'w-56', height: nil,
                        value: nil, rows: '5', html_options: {})
      html_options[:data] ||= {}

      render partial: 'view_components/inputs/text_area', locals: {
        form: form,
        field_name: field_name,
        label: label,
        placeholder: placeholder,
        width: width,
        height: height,
        value: value,
        rows: rows,
        html_options: html_options
      }
    end

    # form component date_select_component
    # @param min minimum date
    # @param maximum date
    def date_select_component(form:, field_name:, min: nil, max: nil, placeholder: 'YYYY-MM-DD')
      render partial: 'view_components/inputs/date_select_component',
             locals: { form:, field_name:, min:, max:, placeholder: }
    end
  end
end
