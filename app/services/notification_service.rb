# frozen_string_literal: true
require 'utilities/queue_client'

class NotificationService
  include Singleton

  QUEUE_CLIENT = Utilities::QueueClient.new

  # each user may have at most 25 latest notification at a time
  MAX_NOTIFICATION_LIMIT = 25

  def self.notify(user, text, ntype = 'info')
    service = NotificationService.instance
    notification = Notification.new(user, text, ntype:)
    service.enqueue_notification(notification)
  end

  def enqueue_notification(notification)
    clear_older_notifications(notification.user)
    enqueue_message(notification)
  end

  def pending_notification_for(user)
    read_all_notifications_for(user).map do |obj|
      Notification.new(user, obj['text'], ntype: obj['ntype'], timestamp: obj['timestamp'])
    end
  end

  def notifications_count_for(user)
    count_all_pending_notifications_for(user)
  end

  def mark_as_read(user, item)
    remove_from_queue(user, item)
  end

  def mark_all_as_read(user)
    remove_all_from_queue(user)
  end

  private

  def enqueue_message(notification)
    QUEUE_CLIENT.enqueue(queue_name(notification.user), notification.encoded_message)
  end

  def read_all_notifications_for(user)
    clear_older_notifications(user)
    messages = QUEUE_CLIENT.read_all(queue_name(user))
    messages
      .map { |message| CGI.unescape(message) }
      .map { |message| Base64.decode64(message) }
      .map { |message| JSON.parse(message) }
  end

  def clear_older_notifications(user)
    QUEUE_CLIENT.trim_to_length(queue_name(user), MAX_NOTIFICATION_LIMIT)
  end

  def remove_from_queue(user, item)
    QUEUE_CLIENT.remove(queue_name(user), item)
  end

  def remove_all_from_queue(user)
    QUEUE_CLIENT.clear_queue(queue_name(user))
  end

  def count_all_pending_notifications_for(user)
    QUEUE_CLIENT.length(queue_name(user))
  end

  def queue_name(user)
    # "notification-#{user.id}"
    "notifications"
  end
end