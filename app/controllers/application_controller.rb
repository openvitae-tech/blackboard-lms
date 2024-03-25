class ApplicationController < ActionController::Base
  def authenticate_platform_admin!
    redirect_to root_path unless current_user&.is_platform_admin?
  end
end
