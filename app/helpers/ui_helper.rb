# frozen_string_literal: true

module UiHelper
  def icon(icon_name, css: nil, span_css: nil)
    file = Rails.cache.fetch("icon:#{icon_name}") do
      Rails.root.join('app', 'assets', 'icons', "#{icon_name}.svg").read
    end

    svg = Nokogiri::HTML::DocumentFragment.parse(file).at_css('svg')
    svg['class'] = css
    content_tag(:span, svg.to_html.html_safe, class: "inline-flex justify-center items-center #{span_css}") # rubocop:disable Rails/OutputSafety
  end

  def button(label: 'Button', type: 'primary', size: 'md', icon_name: nil, icon_position: 'left', tooltip_text: '',
             tooltip_position: 'bottom', disabled: false)
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
        disabled:
      }
    )
  end

  def label_with_icon(icon, label_tag, position)
    ordered = position == 'left' ? [icon, label_tag] : [label_tag, icon]
    ordered.compact.join.html_safe # rubocop:disable Rails/OutputSafety
  end

  def input_field(form: nil, field_name: nil, label: nil, placeholder: 'Enter text', width: 'w-56', left_icon: nil,
                  right_icon: nil, type: 'text_field', options: [], value: 'nil')
    partial_path = "ui/inputs/#{type}"
    partial_path = 'ui/inputs/text_field' unless lookup_context.exists?(partial_path, [], true)

    render partial: partial_path, locals: {
      form:,
      field_name:,
      label:,
      placeholder:,
      width:,
      left_icon:,
      right_icon:,
      type:,
      options:,
      value:
    }
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
end
