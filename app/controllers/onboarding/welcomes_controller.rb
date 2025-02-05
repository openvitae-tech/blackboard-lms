# frozen_string_literal: true

class Onboarding::WelcomesController < ApplicationController
  layout 'onboarding'

  skip_before_action :proceed_to_onboarding_steps

  def new
  end

  def show
  end

  def edit
  end

  def set_password
  end

  def update
    current_user.update(profile_params)

    if current_user.update(profile_params)
      flash.now[:success] = I18n.t('user_settings.updated')
    else
      render :edit
    end
  end

  def update_password
    if current_user.update(password_params)
      current_user.activate
      EVENT_LOGGER.publish_active_user_count(resource)
      redirect_to new_user_session_path, notice: I18n.t('user_settings.password_updated')
    else
      render 'change_password'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :phone, :preferred_local_language)
  end
end