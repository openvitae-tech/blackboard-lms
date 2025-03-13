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

  def button(label: 'Button', type: 'primary', size: 'md', icon_name: nil, 
             icon_position: 'left', width: nil, target: nil, controller: nil)   
    ApplicationController.renderer.render(
      partial: "ui/buttons/#{type}",
      locals: {
        label:,
        type:,
        size:,
        icon_name:,
        icon_position:,
        width:,
        target:,
        controller:
      }
    )
  end

  def label_with_icon(icon, label_tag, position)
    ordered = position == "left" ? [icon, label_tag] : [label_tag, icon]
    ordered.compact.join("").html_safe
  end

  def input_field(f: nil, field_name: nil, label: nil, placeholder: "Enter text", 
                  width: "w-56", left_icon: nil, right_icon: nil, type: "text_field", 
                  options: [], value: nil)

    partial_path = "ui/inputs/#{type}"
    partial_path = "ui/inputs/text_field" unless lookup_context.exists?(partial_path, [], true)
    is_phone = (type == "number" && field_name == :number)

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
      value: value,
      is_phone: is_phone
    }
  end

  def otp_input_field(f:, field_name_prefix:, label: nil, field_count: 4, target: "otp")
    content_tag(:div, class: "flex flex-col gap-4") do
      concat(content_tag(:label, label, class: "text-sm leading-tight")) if label.present?

      concat(
        content_tag(:div, id: "otp", class: "mt-6 flex justify-between gap-4") do
          (1..field_count).map do |i|
            f.number_field "#{field_name_prefix}_#{i}",
                           class: "input-text-otp",
                           maxlength: 1,
                           data: { "#{target}_target" => "input" }
          end.join.html_safe
        end
      )
    end
  end
end
