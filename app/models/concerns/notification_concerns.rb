module NotificationConcerns
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    def notify(user, message, ntype="info")
      notification = Notification.new do |f|
        f.user = user
        f.ntype = ntype
        f.text = message
      end

      notification.save
    end
  end
end