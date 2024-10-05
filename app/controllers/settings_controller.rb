# frozen_string_literal: true

class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_learning_partner
  def show
    authorize :settings
  end
  def edit
    authorize :settings
    @user = current_user
  end

  def update
    authorize :settings
    current_user.update(profile_params)

    if current_user.update(profile_params)
      redirect_to settings_path
    else
      @user = current_user
      render :edit
    end
  end

  def change_password
    authorize :settings
    @user = current_user
  end
  def update_password
    authorize :settings

    if current_user.update(password_params)
      redirect_to settings_path
    else
      @user = current_user
      render 'change_password'
    end
  end

  def team
    authorize :settings

    @learning_partner = current_user.learning_partner

    if current_user.is_admin?
      @members = User.where(role: 'admin')
    else
      @members = @learning_partner.users
      @teams = Team.all
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
    @learning_partner = if current_user.is_admin?
                          nil
                        else
                          current_user.learning_partner
                        end
  end
end
