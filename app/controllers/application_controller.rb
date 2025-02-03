# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include HandleNotFound

  before_action :authenticate_user!
  before_action :set_back_link

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

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

  def set_back_link
    @back_link = params[:source_path].present? ? params[:source_path] : request.referer
  end
end
