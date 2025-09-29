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

    TEXT_SIZES = %w[sm base lg].freeze
    TEXT_WEIGHTS = %w[normal medium bold].freeze
    TEXT_TYPES = %w[primary secondary].freeze
    LINK_TARGETS = %w[_self _blank _parent _top framename].freeze

    def font_weight(weight)
      weight.present? ? "font-#{weight}" : 'font-normal'
    end

    def text_css_class(size, type)
      css = "#{type}-text"
      size == 'base' ? css : "#{css}-#{size}"
    end

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

    def h1_component(text: '', html_options: {})
      render partial: 'view_components/typography/h1_component', locals: {
        text:,
        html_options: html_options.merge(class: 'heading-3xl')
      }
    end

    def h2_component(text: '', html_options: {})
      render partial: 'view_components/typography/h2_component', locals: {
        text:,
        html_options: html_options.merge(class: 'heading-2xl')
      }
    end

    def h3_component(text: '', html_options: {})
      render partial: 'view_components/typography/h3_component', locals: {
        text:,
        html_options: html_options.merge(class: 'heading-xl')
      }
    end

    # @param text - text to be displayed
    # @param size -  sm, base, lg
    # @param weight - normal, medium, bold
    # @param type - primary, secondary
    # @param tag - span, p, div
    # @param html_options - additional html options
    def text_component(text: '', size: 'base', weight: 'normal', type: 'primary', tag: 'span', html_options: {})
      raise 'IncorrectValue - incorrect size value' unless TEXT_SIZES.include?(size)
      raise 'IncorrectValue - incorrect weight value' unless TEXT_WEIGHTS.include?(weight)
      raise 'IncorrectValue - incorrect type value' unless TEXT_TYPES.include?(type)

      css_classes = [text_css_class(size, type), font_weight(weight)]
      render partial: 'view_components/typography/text_component', locals: {
        text:,
        tag:,
        html_options: html_options.merge(class: css_classes.join(' '))
      }
    end

    # @param text - text to be displayed
    # @param url - url to be linked
    # @param target - _blank, _self, _parent, _top, framename
    # @param html_options - additional html options
    def link_component(text:, url: '#', target: '_self', html_options: {})
      raise 'BlankValue - text cannot be blank' if text.blank?
      raise 'InvalidValue - incorrect target value' unless LINK_TARGETS.include?(target)

      render partial: 'view_components/typography/link_component', locals: {
        text:,
        url:,
        html_options: html_options.merge(class: 'text-base-normal', target: target)
      }
    end
  end
end
