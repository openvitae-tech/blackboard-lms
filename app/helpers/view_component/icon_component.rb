# frozen_string_literal: true

module ViewComponent
  module IconComponent
    def icon(icon_name, css: nil, span_css: nil, stroke_width: '1.0')
      file = Rails.cache.fetch("icon:#{icon_name}") do
        Rails.root.join('app', 'assets', 'icons', "#{icon_name}.svg").read
      end

      svg = Nokogiri::HTML::DocumentFragment.parse(file).at_css('svg')
      svg['class'] = css
      svg['stroke-width'] = stroke_width
      content_tag(:span, svg.to_html.html_safe, class: "inline-flex justify-center items-center #{span_css}".strip) # rubocop:disable Rails/OutputSafety
    end
  end
end
