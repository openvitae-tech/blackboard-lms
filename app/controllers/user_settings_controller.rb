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
      bypass_sign_in(@user)
      redirect_to user_settings_path, notice: I18n.t('user_settings.password_updated')
    else
      render 'change_password'
    end
  end
  def edit_profile_picture
    authorize :user_settings
  end

  def update_profile_picture
    authorize :user_settings
    file = params.dig(:user, :profile_picture)
    unless file.present?
      @error = "Please select a profile picture"
      render :edit_profile_picture, status: :unprocessable_entity
      return
    end

    if @user.update(profile_picture: file)
      flash[:success] = "Profile picture updated successfully"
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to user_settings_path }
      end
    else
      @error = @user.errors[:profile_picture].first
      render :edit_profile_picture, status: :unprocessable_entity
    end
  end

  def confirm_logout
    authorize :user_settings
  end

  def edit_email
    authorize :user_settings
  end

  def update_email
    authorize :user_settings
    new_email = params.dig(:user, :email).to_s.strip

    if new_email.blank?
      @user.errors.add(:email, "can't be blank")
      render :edit_email, status: :unprocessable_entity
      return
    end

    unless new_email.match?(User::EMAIL_REGEXP)
      @user.errors.add(:email, "is invalid")
      render :edit_email, status: :unprocessable_entity
      return
    end

    if User.where.not(id: @user.id).exists?(email: new_email)
      @user.errors.add(:email, "has already been taken")
      render :edit_email, status: :unprocessable_entity
      return
    end
    session[:pending_email] = new_email
    @user.update(email: new_email)
    flash[:success] = I18n.t('user_settings.email_verification_sent', email: new_email)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to user_settings_path }
    end
  end

  def edit_phone_number
    authorize :user_settings
  end

  def update_phone_number
    authorize :user_settings
    phone = params.dig(:user, :phone)
    country_code = params.dig(:user, :phone_code)

    if User.where.not(id: @user.id).exists?(phone:)
      @user.errors.add(:phone, "has already been taken")
      render :edit_phone_number, status: :unprocessable_entity
      return
    end

    session[:pending_phone] = phone
    session[:pending_country_code] = country_code

    if Rails.env.production?
      mobile_number = MobileNumber.new(value: phone, country_code: country_code)
      Auth::OtpService.new(mobile_number, name: @user.name).generate_otp
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to edit_phone_number_user_settings_path }
    end
  end

  def verify_phone_number
    authorize :user_settings
    otp_valid =
      if Rails.env.production?
        mobile_number = MobileNumber.new(value: session[:pending_phone], country_code: session[:pending_country_code])
        Auth::OtpService.new(mobile_number).verify_otp(params[:otp])
      else
        params[:otp].to_s == User::TEST_OTP.to_s
      end

    if otp_valid
      @user.update!(phone: session.delete(:pending_phone), country_code: session.delete(:pending_country_code))
      flash[:success] = I18n.t('user_settings.phone_updated')
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to user_settings_path }
      end
    else
      @error = I18n.t('user_settings.invalid_otp')
      render :verify_phone_number, status: :unprocessable_entity
    end
  end

  def send_verification_email
    authorize :user_settings
    @user.send_confirmation_instructions
    flash[:success] = I18n.t('user_settings.email_verification_sent', email: @user.email)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to user_settings_path }
    end
  end


  private

  def profile_params
    params.require(:user).permit(:name, :dob, :gender, :preferred_local_language)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def set_learning_partner
    @learning_partner =  @user.is_admin? ? nil : @user.learning_partner
  end

  def set_user
    @user = current_user
  end
end
