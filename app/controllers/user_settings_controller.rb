# frozen_string_literal: true

class UserSettingsController < ApplicationController
  before_action :set_user
  before_action :set_learning_partner

  def show
    authorize :user_settings
  end
  def edit
    authorize :user_settings
  end

  def update
    authorize :user_settings
    @user.update(profile_params)

    if @user.update(profile_params)
      flash.now[:success] = I18n.t('user_settings.updated')
    else
      render :edit
    end
  end

  def change_password
    authorize :user_settings
  end
  def update_password
    authorize :user_settings

    if @user.update(password_params)
      sign_in(current_user, bypass: true)
      redirect_to user_settings_path, notice: I18n.t('user_settings.password_updated')
    else
      render 'change_password'
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :phone)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def set_learning_partner
    @learning_partner = if @user.is_admin?
                          nil
                        else
                          @user.learning_partner
                        end
  end

  def set_user
    @user = current_user
  end
end
