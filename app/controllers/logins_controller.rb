# frozen_string_literal: true

class LoginsController < ApplicationController
  layout 'devise'

  before_action :user_exists?, only: %i[otp create]
  skip_before_action :authenticate_user!

  def new; end

  def otp
    @mobile_number = login_params[:mobile_number]
    service = LoginWithOtpService.instance

    if @user_exists
      user = User.where(phone: @mobile_number).first
      service.set_and_send_otp(@mobile_number, user)
    else
      redirect_to new_login_path, notice: t('login.incorrect_phone')
    end
  end

  def create
    service = LoginWithOtpService.instance

    if @user_exists
      user = User.where(phone: login_params[:mobile_number]).first
      if service.valid_otp?(user, login_params[:otp])
        build_user_session(user)
        user.clear_otp!
        redirect_to after_sign_in_path_for(user), notice: t('devise.sessions.signed_in')
      else
        flash.now[:error] = t('login.invalid_or_incorrect_otp')
      end
    else
      redirect_to new_login_path, notice: t('login.incorrect_mobile_or_otp')
    end
  end

  private

  def login_params
    params.require(:login).permit(:mobile_number, :otp)
  end

  def build_user_session(user)
    sign_in user
  end

  def user_exists?
    @user_exists = User.exists?(phone: login_params[:mobile_number])
  end
end
