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
    @active_nav = params[:active_nav].presence || case controller_name
    when 'dashboards' then 'dashboards'
    when 'programs'
      if action_name == 'explore'
        'courses'
      elsif action_name == 'index' || action_name == 'new' || action_name == 'create'
        'programs'
      elsif params[:mode].blank? || params[:mode] == Program::LEARNER_MODE
        # 'my_courses' is a synthetic sentinel value - not a real controller name.
        # It differentiates navigating to a program from the courses/my courses flow
        # vs navigating from the programs sidebar, so the correct sidebar item is highlighted.
        'my_courses'
      else
        'programs'
      end
    when 'teams' then 'teams'
    when 'my_profiles' then 'my_profiles'
    when 'supports' then 'supports'
    when 'learning_partners', 'certificate_templates' then 'learning_partners'
    when 'settings', 'tags' then 'settings'
    when 'user_settings' then 'user_settings'
    when 'courses', 'lessons', 'course_modules', 'quizzes',
         'assessments', 'materials', 'scorms', 'enrollments'
      'courses'
    else
      # neo_components engine controllers (e.g. neo_components/ui/components)
      # are settings-related pages, all other unknown controllers default to courses
      if controller_path.start_with?('neo_components/')
        'settings'
      else
        'courses'
      end
    end
  end
end
