# frozen_string_literal: true

class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_learning_partner

  def show
    authorize :settings
  end
  def edit
    authorize :settings
  end

  def update
    authorize :settings
    @user.update(profile_params)

    if @user.update(profile_params)
      flash.now[:success] = I18n.t('settings.updated')
    else
      render :edit
    end
  end

  def change_password
    authorize :settings
  end
  def update_password
    authorize :settings

    if @user.update(password_params)
      redirect_to new_user_session_path, notice: I18n.t('settings.password_updated')
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
