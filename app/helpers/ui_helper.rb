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
end
