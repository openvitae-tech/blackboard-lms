# frozen_string_literal: true

class NotificationsController < ApplicationController
  def index
    @notifications = notification_service.pending_notification_for(current_user)
  end

  def count
    @notifications_count = notification_service.notifications_count_for(current_user)
  end

  def clear
    notification_service.mark_all_as_read(current_user)
  end

  def mark_as_read
    notification_service.mark_as_read(current_user, params[:message])
    @notifications = notification_service.pending_notification_for(current_user)
    if params[:redirect_url].present?
      redirect_to params[:redirect_url]
      return
    end
  end

  private

  def notification_service
    NotificationService.instance
  end
end
