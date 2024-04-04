class ApplicationController < ActionController::Base
  include Pundit::Authorization
  def authenticate_admin!
    redirect_to root_path unless current_user&.is_admin?
  end
end
