# frozen_string_literal: true

module ViewComponent
  module ChipComponent
    COLOR_SCHEMES = %w[primary danger].freeze

    def chip_component(text: '', icon_name: nil, close: false, colorscheme: 'primary')
      raise "Incorrect color scheme #{colorscheme}" unless COLOR_SCHEMES.include? colorscheme

      bg_style, text_style, icon_style, close_style =
        case colorscheme
        when 'primary' then %w[bg-primary-light-100 text-primary-dark text-primary text-primary]
        when 'danger' then %w[bg-danger-light text-primary-dark text-danger-dark text-danger-dark]
        end

      render partial: 'view_components/chip_component/chip_component', locals: {
        text:, icon_name:, close:, bg_style:, text_style:, icon_style:, close_style:
      }
    end
  end
end
