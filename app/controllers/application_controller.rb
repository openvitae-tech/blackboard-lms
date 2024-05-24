class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  def authenticate_admin!
    redirect_to root_path unless current_user&.is_admin?
  end

  def user_not_authorized
    render 'pages/index', status: 401
    nil
  end
end
