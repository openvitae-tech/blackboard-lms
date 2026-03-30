# frozen_string_literal: true

module ViewComponent
  module ChipComponent
    COLOR_SCHEMES = {
      'primary' => %w[
        bg-primary-light-100
        text-primary-dark
        text-primary
        text-primary
        border-0
      ],
      'primary_lite' => %w[
        bg-primary-light-50
        text-primary-dark
        text-primary
        text-primary
        border-0
      ],
      'danger' => %w[
        bg-danger-light
        text-primary-dark
        text-danger-dark
        text-danger-dark
        border-0
      ],
      'input' => %w[
        bg-primary-light-50
        text-primary-dark
        text-primary
        text-primary
        border-slate-grey-light
      ]
    }.freeze

    def chip_component(text: '', icon_name: nil, close: false, colorscheme: 'primary')
      styles = COLOR_SCHEMES[colorscheme]
      raise "Incorrect color scheme #{colorscheme}" unless styles

      bg_style, text_style, icon_style, close_style, border_style = styles

      render partial: 'view_components/chip_component/chip_component', locals: {
        text:,
        icon_name:,
        close:,
        bg_style:,
        text_style:,
        icon_style:,
        close_style:,
        border_style:
      }
    end
  end
end
