# frozen_string_literal: true

class LoginsController < ApplicationController
  layout 'devise'

  before_action :user_exists?, only: %i[otp create]
  skip_before_action :authenticate_user!

  def new; end

  def otp
    service = LoginWithOtpService.instance

    if @user_exists
      user = User.where(phone: @mobile_number.value).first
      service.generate_and_send_otp(user)
    else
      redirect_to new_login_path, notice: t('login.incorrect_phone')
    end
  end

  def create
    service = LoginWithOtpService.instance

    if @user_exists
      user = User.where(phone: @mobile_number.value).first
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
    @mobile_number = MobileNumber.new(value: login_params[:mobile_number])
    @user_exists = @mobile_number.valid? && User.exists?(phone: @mobile_number.value)
  end
end
