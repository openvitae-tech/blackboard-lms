# frozen_string_literal: true

module UiHelper
  ICON_CACHE = {}

  def icon(icon_name, css: nil, span_css: nil)
    file = ICON_CACHE.fetch(
      icon_name,
      ICON_CACHE[icon_name] = File.read(Rails.root.join("app", "assets", "icons", "#{icon_name}.svg"))
    )

    svg = Nokogiri::HTML::DocumentFragment.parse(file).at_css("svg")
    svg["class"] = css
    content_tag(:span, svg.to_html.html_safe, class: "inline-flex justify-center items-center #{span_css}")
  end

  def button(label: 'Button', type: 'primary', size: 'md', icon_name: nil, icon_position: 'left')
    ApplicationController.renderer.render(
      partial: "ui/buttons/#{type}",
      locals: {
        label:,
        type:,
        size:,
        icon_name:,
        icon_position:
      }
    )
  end

  def label_with_icon(icon, label_tag, position)
    ordered = position == "left" ? [icon, label_tag] : [label_tag, icon]
    ordered.compact.join("").html_safe
  end
  def input_field(f: nil, field_name: nil, label: nil, placeholder: "Enter text", width: "w-56", left_icon: nil, right_icon: nil, type: "text_field", options: [],value:"nil")
    partial_path = "ui/inputs/#{type}"
    partial_path = "ui/inputs/text_field" unless lookup_context.exists?(partial_path, [], true)
  
    render partial: partial_path, locals: {
      f: f,
      field_name: field_name,
      label: label,
      placeholder: placeholder,
      width: width,
      left_icon: left_icon,
      right_icon: right_icon,
      type: type,
      options: options,
      value:value
    }
  end
  def table_columns(table_type)
    case table_type
    when "tag"
      [
        { name: "Name", span: "col-span-4", alignment: "justify-start", field: :name },
        { name: "Type", span: "col-span-4", alignment: "justify-start", field: :tag_type },
        { name: "Actions", span: "col-span-4", alignment: "justify-end", is_action: true }
      ]
    when "member"
      [
        { name: "Name", span: "col-span-4", alignment: "justify-start", field: :name },
        { name: "Email", span: "col-span-3", alignment: "justify-start", field: :email },
        { name: "Phone", span: "col-span-2", alignment: "justify-start", field: :phone },
        { name: "Role", span: "col-span-1", alignment: "justify-start", field: :role },
        { name: "Actions", span: "col-span-2", alignment: "justify-end", is_action: true }
      ]
    else
      []
    end
  end
end
