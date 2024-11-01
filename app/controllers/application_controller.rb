# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def authenticate_manager!
    redirect_to new_user_session_path unless current_user&.is_manager? || current_user&.is_owner?
  end

  def authenticate_admin!
    redirect_to new_user_session_path unless current_user&.is_admin?
  end

  def user_not_authorized
    redirect_to error_401_path, notice: I18n.t('pundit.unauthorized')
  end

  def after_sign_in_path_for(user)
    if user.is_manager? || user.is_owner?
      dashboards_path
    elsif user.is_admin?
      learning_partners_path
    else
      courses_path
    end
  end
end
