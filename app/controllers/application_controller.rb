class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected
  def authenticate_admin!
    redirect_to new_user_session_path unless current_user&.is_admin?
  end

  def user_not_authorized
    redirect_to error_401_path
  end

  def after_sign_in_path_for(user)
    dashboard_path
  end
end
