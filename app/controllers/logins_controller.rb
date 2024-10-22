# frozen_string_literal: true

class LoginsController < ApplicationController
  layout 'devise'

  def new; end

  def otp
    @mobile_number = login_params[:mobile_number]
    user = User.find_by!(phone: @mobile_number)

    service = LoginWithOtpService.instance
    service.set_and_send_otp(@mobile_number, user)
  rescue ActiveRecord::RecordNotFound
    redirect_to new_login_path, notice: t('login.incorrect_phone')
  end

  def create
    user = User.find_by!(phone: login_params[:mobile_number])
    service = LoginWithOtpService.instance

    if service.valid_otp?(user, login_params[:otp])
      build_user_session(user)
      redirect_to after_sign_in_path_for(user), notice: t('devise.sessions.signed_in')
    else
      redirect_to new_login_path, notice: t('login.invalid_or_incorrect_otp')
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to new_login_path, notice: t('login.incorrect_mobile_or_otp')
  end

  private

  def login_params
    params.require(:login).permit(:mobile_number, :otp)
  end

  def build_user_session(user)
    sign_in user
  end
end
