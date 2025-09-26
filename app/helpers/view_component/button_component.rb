# frozen_string_literal: true

module ViewComponent
  module ButtonComponent
    class ButtonComponent
      BUTTON_TYPES = %w[solid outline].freeze
      BUTTON_SIZES = %w[sm md lg].freeze
      COLOR_SCHEMES = %w[primary secondary danger].freeze
      ICON_POSITIONS = %w[left right].freeze
      TOOLTIP_POSITIONS = %w[top left bottom right].freeze
      DISABLED_CLASS = %w[opacity-50 cursor-not-allowed].freeze

      attr_accessor :label, :type, :colorscheme, :size, :icon_name, :icon_position, :tooltip_text, :tooltip_position,
                    :disabled, :html_options, :color_mapping

      def initialize(label:, type:, colorscheme:, size:, icon_name:, icon_position:, tooltip_text:, tooltip_position:,
                     disabled:, html_options:)
        self.label = label
        self.type = type
        self.size = size
        self.colorscheme = colorscheme
        self.icon_name = icon_name
        self.icon_position = icon_position
        self.tooltip_text = tooltip_text
        self.tooltip_position = tooltip_position
        self.disabled = disabled
        self.html_options = html_options
        # validation
        raise "Incorrect button type: #{type}" unless BUTTON_TYPES.include? type
        raise "Incorrect button size: #{size}" unless BUTTON_SIZES.include? size
        raise "Incorrect color scheme: #{colorscheme}" unless COLOR_SCHEMES.include? colorscheme
        raise "Incorrect icon_position: #{icon_position}" unless ICON_POSITIONS.include? icon_position
        raise "Incorrect tooltip_position: #{tooltip_position}" unless TOOLTIP_POSITIONS.include? icon_position

        self.color_mapping = button_color_scheme_mapping
      end

      def base_styles
        styles = ['inline-flex w-full border items-center justify-center gap-2']
        styles.append('disabled-button') if disabled
        styles.join(' ')
      end

      def color_styles
        [
          color_mapping[:border], "hover:#{color_mapping[:border_hover]}",
          color_mapping[:bg], "hover:#{color_mapping[:bg_hover]}",
          color_mapping[:text], "hover:#{color_mapping[:text_hover]}"
        ].join(' ')
      end

      def sizing_styles
        case size
        when 'sm'
          'h-6 md:h-9 rounded-sm md:rounded-md px-3 md:px-4 py-1 md:py-2'
        when 'md'
          'h-9 md:h-10 rounded-md px-4 py-2'
        when 'lg'
          'h-10 md:h-14 gap-2 rounded-md md:rounded-lg px-4 md:px-6 py-2 md:py-3'
        else
          ''
        end
      end

      def text_styles
        styles = case size
                 when 'sm'
                   'text-xs md:text-sm font-medium leading-4 md:leading-5'
                 when 'md'
                   'text-sm md:text-base font-medium leading-5 md:leading-6'
                 when 'lg'
                   'text-base md:text-xl font-medium md:font-semibold leading-6 md:leading-7'
                 else
                   ''
                 end

        "#{styles} font-['Poppins']"
      end

      def icon_styles
        case size
        when 'sm'
          'h-4 md:h-5 w-4 md:w-5'
        when 'md'
          'h-5 w-5 md:h-6 md:w-6'
        when 'lg'
          'h-6 w-6 md:h-7 md:w-7'
        else
          ''
        end
      end

      private

      def button_color_scheme_mapping
        {
          solid: {
            primary: {
              bg: disabled ? 'bg-primary-light-50' : 'bg-primary',
              bg_hover: 'bg-primary-light',
              border: disabled ? 'border-disabled-color' : 'border-primary',
              border_hover: 'border-primary-light',
              text: disabled ? 'text-disabled-color' : 'text-white-light',
              text_hover: 'text-white'
            },
            secondary: {
              bg: disabled ? 'bg-secondary-light' : 'bg-secondary',
              bg_hover: 'bg-secondary-dark',
              border: disabled ? 'border-disabled-color' : 'border-secondary',
              border_hover: 'border-secondary-dark',
              text: disabled ? 'text-disabled-color' : 'text-white',
              text_hover: 'text-white'
            },
            danger: {
              bg: disabled ? 'bg-danger-light' : 'bg-danger-dark',
              bg_hover: 'bg-danger',
              border: disabled ? 'border-disabled-color' : 'border-danger-dark',
              border_hover: 'border-danger',
              text: disabled ? 'text-disabled-color' : 'text-white-light',
              text_hover: 'text-white'
            }
          },
          outline: {
            primary: {
              bg: 'bg-white',
              bg_hover: 'bg-white',
              border: disabled ? 'border-disabled-color' : 'border-primary',
              border_hover: 'border-primary-light',
              text: disabled ? 'text-disabled-color' : 'text-primary',
              text_hover: 'text-primary-light'
            },
            secondary: {
              bg: 'bg-white',
              bg_hover: 'bg-white',
              border: disabled ? 'border-disabled-color' : 'border-secondary',
              border_hover: 'border-secondary-dark',
              text: disabled ? 'text-disabled-color' : 'text-secondary',
              text_hover: 'text-secondary-dark'
            },
            danger: {
              bg: 'bg-white',
              bg_hover: 'bg-white',
              border: disabled ? 'border-disabled-color' : 'border-danger-dark',
              border_hover: 'border-danger',
              text: disabled ? 'text-disabled-color' : 'text-danger-dark',
              text_hover: 'text-danger'
            }
          }
        }[type.to_sym][colorscheme.to_sym]
      end
    end

    def label_with_icon(icon, label_tag, position)
      ordered = position == 'left' ? [icon, label_tag] : [label_tag, icon]
      safe_join(ordered.compact)
    end

    def button(
      label: nil,
      type: 'primary',
      size: 'md',
      icon_name: nil,
      icon_position: 'left',
      tooltip_text: '',
      tooltip_position: 'bottom',
      disabled: false,
      html_options: {}
    )
      render(
        partial: "view_components/buttons/#{type}",
        locals: {
          label:,
          type:,
          size:,
          icon_name:,
          icon_position:,
          tooltip_text:,
          tooltip_position:,
          disabled:,
          html_options:
        }
      )
    end

    def button_component(
      label: 'Button',
      type: 'solid',
      size: 'md',
      colorscheme: 'primary',
      icon_name: '',
      icon_position: 'left',
      tooltip_text: '',
      tooltip_position: 'bottom',
      disabled: false,
      html_options: {}
    )
      button = ButtonComponent.new(
        label:, type:, size:, colorscheme:, icon_name:, icon_position:, tooltip_text:, tooltip_position:, disabled:, html_options:
      )

      render(
        partial: 'view_components/button_component/button',
        locals: { button: }
      )
    end
  end
end
