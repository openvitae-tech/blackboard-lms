# frozen_string_literal: true

module TypographyHelper
  def link_text_component(text, link, html_options = {})
    render partial: 'ui/typography/linked_text_component', locals: {
      text:,
      link:,
      html_options:
    }
  end
end
