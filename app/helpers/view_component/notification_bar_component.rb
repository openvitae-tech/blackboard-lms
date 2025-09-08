# frozen_string_literal: true

module ViewComponent
  module NotificationBarComponent
    def notification_bar(
      text: nil,
      text_color: 'text-letter-color',
      bg_color: 'bg-white',
      icon_color: 'bg-letter-color'
    )

      render(
        partial: 'view_components/notification_bar/notification_bar',
        locals: {
          text:,
          text_color:,
          icon_color:,
          bg_color:
        }
      )
    end
  end
end
