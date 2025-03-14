# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]
  before_action :authenticate_user!, only: [:destroy]

  def create
    super do
      if resource.errors.empty?
        EVENT_LOGGER.publish_user_login(resource, 'password')
      end
    end
  end

  def destroy
    id = current_user.id
    team_id = current_user.team_id
    partner_id = current_user.learning_partner_id
    destroy_impersonation(id) if impersonating?

    super do
      EVENT_LOGGER.publish_user_logout(id, team_id, partner_id)
    end
  end

  protected

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end
end
