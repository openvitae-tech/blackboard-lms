# frozen_string_literal: true

module ViewComponent
  module Card
    module ContentTypeCardComponent
      def content_type_card_component(
        title:,
        description:,
        icon_name:,
        radio_value:,
        radio_name:,
        highlights: [],
        caption: nil,
        selected: false,
        disabled: false
      )
        render partial: 'view_components/cards/content_type_card_component', locals: {
          title:,
          description:,
          icon_name:,
          radio_value:,
          radio_name:,
          highlights:,
          caption:,
          selected:,
          disabled:,
          label_classes: if disabled
                           'opacity-40 pointer-events-none border-line-colour'
                         else
                           'cursor-pointer border-line-colour hover:border-primary hover:ring-2 hover:ring-primary ' \
                             'has-[input:checked]:bg-primary-light-50 has-[input:checked]:border-primary ' \
                             'has-[input:checked]:ring-2 has-[input:checked]:ring-primary'
                         end
        }
      end
    end
  end
end
