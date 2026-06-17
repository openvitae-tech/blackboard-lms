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
      ],
      'secondary' => %w[
        bg-secondary
        text-primary-dark
        text-primary-dark
        text-primary-dark
        border-0
      ],
      'gold' => %w[
        bg-gold-light
        text-primary-dark
        text-primary-dark
        text-primary-dark
        border-slate-grey-light
      ],
      'published' => %w[
        bg-primary-light-200
        text-black
        text-black
        text-black
        border-line-colour
      ],
      'unpublished' => %w[
        bg-line-colour-light
        text-black
        text-black
        text-black
        border-line-colour
      ],
      'transparent' => %w[
        bg-transparent
        text-black
        text-black
        text-black
        border-line-colour
      ]
    }.freeze

    def chip_component(text: '', icon_name: nil, close: false, colorscheme: 'primary', pill: false)
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
        border_style:,
        pill:
      }
    end
  end
end
