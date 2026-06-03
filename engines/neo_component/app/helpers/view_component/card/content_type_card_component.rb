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
          disabled:
        }
      end
    end
  end
end
