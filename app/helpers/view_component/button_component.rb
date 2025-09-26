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

      BUTTON_SIZE_MAPPING = {
        sm: 'btn-sm',
        md: 'btn-md',
        lg: 'btn-lg'
      }.freeze

      BUTTON_COLOUR_SCHEME_MAPPING = {
        solid: {
          primary: 'btn-solid-primary',
          secondary: 'btn-solid-secondary',
          danger: 'btn-solid-danger'
        },
        outline: {
          primary: 'btn-outline-primary',
          secondary: 'btn-outline-secondary',
          danger: 'btn-outline-danger'
        }
      }.freeze

      BUTTON_DISABLED_MAPPING = {
        solid: {
          primary: 'btn-solid-primary-disabled',
          secondary: 'btn-solid-secondary-disabled',
          danger: 'btn-solid-danger-disabled'
        },
        outline: {
          primary: 'btn-outline-primary-disabled',
          secondary: 'btn-outline-secondary-disabled',
          danger: 'btn-outline-danger-disabled'
        }
      }.freeze

      ICON_STYLES_MAPPING = {
        sm: 'btn-icon-sm',
        md: 'btn-icon-md',
        lg: 'btn-icon-lg'
      }.freeze

      BUTTON_TEXT_STYLE_MAPPING = {
        sm: 'btn-text-sm',
        md: 'btn-text-md',
        lg: 'btn-text-lg'
      }.freeze

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
        raise "Incorrect tooltip_position: #{tooltip_position}" unless TOOLTIP_POSITIONS.include? tooltip_position

        self.color_mapping = color_scheme_mapping
      end

      def base_styles
        styles = ['btn-base']
        styles.append('btn-disabled') if disabled
        styles.join(' ')
      end

      def color_styles
        color_mapping
      end

      def sizing_styles
        BUTTON_SIZE_MAPPING[size.to_sym]
      end

      def text_styles
        style = BUTTON_TEXT_STYLE_MAPPING[size.to_sym]
        ['btn-text-base', style].join(' ')
      end

      def icon_styles
        ICON_STYLES_MAPPING[size.to_sym]
      end

      private

      def color_scheme_mapping
        if disabled
          ['btn-disabled', BUTTON_DISABLED_MAPPING[type.to_sym][colorscheme.to_sym]]
        else
          BUTTON_COLOUR_SCHEME_MAPPING[type.to_sym][colorscheme.to_sym]
        end
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
        label:,
        type:,
        size:,
        colorscheme:,
        icon_name:,
        icon_position:,
        tooltip_text:,
        tooltip_position:,
        disabled:,
        html_options:
      )

      render(
        partial: 'view_components/button_component/button',
        locals: { button: }
      )
    end
  end
end
