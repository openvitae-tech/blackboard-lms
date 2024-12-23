# frozen_string_literal: true

class NotificationsController < ApplicationController

  def index
    @notifications = current_user.notifications.order('id desc').limit(100)
  end
end
