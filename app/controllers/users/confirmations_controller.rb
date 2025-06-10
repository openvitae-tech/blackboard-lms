# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    super do |resource|
      if resource.errors.empty?
        EVENT_LOGGER.publish_email_verified(resource)
      end
    end
  end
end
