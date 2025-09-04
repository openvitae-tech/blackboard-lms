# frozen_string_literal: true

module ViewComponent
  module TypographyComponent
    HEADING_SIZE = {
      'xs' => 'text-base font-semibold',
      'sm' => 'text-lg font-semibold',
      'md' => 'text-xl font-semibold',
      'lg' => 'text-2xl font-semibold',
      'xl' => 'text-3xl font-semibold'
    }.freeze

    def link_text_component(text, link, html_options = {})
      render partial: 'view_components/typography/linked_text_component', locals: {
        text:,
        link:,
        html_options:
      }
    end

    # @param size - xs, sm, md, lg, xl
    def heading_component(text:, size: 'md')
      raise 'BlankValue - heading cannot be blank' if text.blank?
      raise 'IncorrectValue - incorrect size value' unless %w[xs sm md lg xl].include?(size)

      render partial: 'view_components/typography/heading_component', locals: {
        text:,
        css: HEADING_SIZE[size]
      }
    end
  end
end
