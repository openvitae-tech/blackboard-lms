# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include HandleNotFound
  include UserOnboarding
  include Impersonation

  before_action :authenticate_user!
  before_action :set_back_link
  before_action :set_active_nav

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :impersonating?

  protected

  def authenticate_admin!
    redirect_to new_user_session_path unless current_user&.is_admin?
  end

  def authenticate_user!
    if user_signed_in? || devise_controller?
      super
    else
      redirect_to new_login_path
    end
  end

  def impersonating?
    fetch_impersonated_user(current_user.id).present? && current_user.is_support?
  end

  def user_not_authorized
    redirect_to error_401_path, notice: I18n.t('pundit.unauthorized')
  end

  def after_sign_in_path_for(user)
    stored_location_for(:user) || if user.privileged_user?
      dashboards_path
    elsif user.is_admin?
      learning_partners_path
    else
      courses_path
    end
  end

  def set_back_link
    @back_link = params[:source_path].present? ? params[:source_path] : request.referer
  end

  def set_active_nav
    top_level_controllers = %w[dashboards my_profiles programs teams supports learning_partners]

    if top_level_controllers.include?(controller_name) || (controller_name == 'courses' && action_name == 'index')
      session[:active_nav] = controller_name
    end

    @active_nav = session[:active_nav] || controller_name
  end
end