# frozen_string_literal: true

module UiHelper
  def icon(icon_name, css: nil, span_css: nil)
    file = Rails.cache.fetch("icon:#{icon_name}") do
      Rails.root.join('app', 'assets', 'icons', "#{icon_name}.svg").read
    end

    svg = Nokogiri::HTML::DocumentFragment.parse(file).at_css('svg')
    svg['class'] = css
    content_tag(:span, svg.to_html.html_safe, class: "inline-flex justify-center items-center #{span_css}".strip) # rubocop:disable Rails/OutputSafety
  end

  def button(label: nil, type: 'primary', size: 'md', icon_name: nil, icon_position: 'left', tooltip_text: '',
             tooltip_position: 'bottom', disabled: false, html_options: {})
    ApplicationController.renderer.render(
      partial: "ui/buttons/#{type}",
      locals: {
        label:,
        type:,
        size:,
        icon_name:,
        icon_position:,
        tooltip_text:,
        tooltip_position:,
        disabled:,
        html_options:
      }
    )
  end

  def label_with_icon(icon, label_tag, position)
    ordered = position == 'left' ? [icon, label_tag] : [label_tag, icon]
    ordered.compact.join.html_safe # rubocop:disable Rails/OutputSafety
  end

  def input_field(form: nil, field_name: nil, label: nil,
                  placeholder: nil, width: 'w-56', height: nil, left_icon: nil, right_icon: nil, type: 'text',
                  options: [], value: nil, rows: '5', option: nil, html_options: {})
    partial_path = 'ui/inputs/text_field' unless lookup_context.exists?(partial_path, [], true)

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
    render partial: 'ui/inputs/radio_field', locals: {
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
    render partial: 'ui/inputs/dropdown_field', locals: {
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
                     value: nil)
    render partial: 'ui/inputs/checkbox_field', locals: {
      form:,
      field_name:,
      label:,
      width:,
      value:
    }
  end

  def input_mobile(form:, field_name:, placeholder: 'Enter 10-digit mobile number',
                   value: nil, label: nil, flag: nil, html_options: {})
    value ||= form.object.public_send(field_name) if form.object.respond_to?(field_name)

    render partial: 'ui/inputs/mobile_field', locals: {
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

  def table_cell_name(row_data, avatar: false)
    { partial: 'shared/components/table_cell_name', locals: { row_data:, avatar: } }
  end

  def table_cell_role(row_data)
    { partial: 'shared/components/table_cell_role', locals: { row_data: } }
  end

  def table_actions(row_data, actions = [])
    actions.each do |action|
      action[:data] ||= {}
      action[:data][:turbo_frame] = action[:turbo_frame] if action[:turbo_frame].present?
    end

    { partial: 'shared/components/table_actions', locals: { row_data:, actions: } }
  end

  def notification_bar(text: nil, text_color: 'text-letter-color', bg_color: 'bg-white',
                       icon_color: 'bg-letter-color')
    ApplicationController.renderer.render(
      partial: 'ui/notification_bars/notification_bar',
      locals: {
        text:,
        text_color:,
        icon_color:,
        bg_color:
      }
    )
  end

  def paginator(collection, path:)
    render partial: 'ui/pagination/paginator', locals: { collection: collection, path: path }
  end

  # form component date_select_component
  # @param min minimum date
  # @param maximum date
  def date_select_component(form:, field_name:, min: nil, max: nil, placeholder: 'YYYY-MM-DD')
    render partial: 'ui/inputs/date_select_component', locals: { form:, field_name:, min:, max:, placeholder: }
  end

  # modal box component
  # @param title - modal title
  def modal_component(title:, &)
    block_content = capture(&) if block_given?
    render partial: 'ui/modals/modal_component', locals: { title:, body: block_content }
  end

  def course_carousal_component(courses:, title:, count:, load_path:)
    render partial: 'ui/app/course_carousal/course_carousal_component', locals: { courses:, title:, count:, load_path: }
  end

  def course_carousal_body_component(courses:)
    render partial: 'ui/app/course_carousal/course_carousal_body_component', locals: { courses: }
  end

  def course_card_component(course:, enrollment: nil)
    render partial: 'ui/app/course_carousal/course_card_component', locals: { course:, enrollment: }
  end

  def course_select_component(search_context:, submit_path:, courses: [], tags: [], cancel_link: nil,
                              show_duration: false)
    render partial: 'ui/app/course_select/course_select_component',
           locals: { search_context:, courses:, tags:, cancel_link:, show_duration:, submit_path: }
  end

  def _course_select_search_component(search_context:, tags:)
    render partial: 'ui/app/course_select/search_component', locals: { search_context:, tags: }
  end

  def _course_select_sidebar_component(form:, tags:)
    render partial: 'ui/app/course_select/sidebar_component', locals: { form:, tags: }
  end

  def _course_select_list_component(search_context:, courses:)
    render partial: 'ui/app/course_select/list_component',
           locals: { search_context:, courses: }
  end

  def _course_select_list_item_component(course:)
    render partial: 'ui/app/course_select/list_item_component', locals: { course: }
  end

  def _course_select_load_more(search_context:, courses:)
    render partial: 'ui/app/course_select/load_more', locals: { search_context:, courses: }
  end
end
