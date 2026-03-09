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

  def change_profile_picture
    authorize :user_settings
    if request.post?
      file = params.dig(:user, :profile_picture)
      unless file.present?
        @error = "Please select a profile picture"
        render :change_profile_picture, status: :unprocessable_entity
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
        render :change_profile_picture, status: :unprocessable_entity
      end
    end
  end

  def confirm_logout
    authorize :user_settings
  end

  def change_email
    authorize :user_settings
    if request.post?
      new_email = params.dig(:user, :email).to_s.strip

      unless new_email.match?(User::EMAIL_REGEXP)
        @error = "Please enter a valid email address"
        render :change_email, status: :unprocessable_entity
        return
      end

      if @user.update(email: new_email)
        flash[:success] = I18n.t('user_settings.email_verification_sent', email: new_email)
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to user_settings_path }
        end
      else
        @error = @user.errors[:email].any? { |e| e.include?("taken") } ? "Email already taken" : @user.errors[:email].first
        render :change_email, status: :unprocessable_entity
      end
    end
  end

  def change_phone_number
    authorize :user_settings
    if request.post?
      phone = params.dig(:user, :phone)
      country_code = params.dig(:user, :phone_code)

      if User.where.not(id: @user.id).exists?(phone:)
        @error = "Phone has already been taken"
        render :change_phone_number, status: :unprocessable_entity
        return
      end

      session[:pending_phone] = phone
      session[:pending_country_code] = country_code
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to change_phone_number_user_settings_path }
      end
    end
  end

  def verify_phone_number
    authorize :user_settings

    if Rails.env.production?
      phone = MobileNumber.new(value: session[:pending_phone], country_code: session[:pending_country_code])
      otp_service = Auth::OtpService.new(phone)
      otp_verified = otp_service.verify_otp(params[:otp])
    else
      otp_verified = params[:otp].to_s == User::TEST_OTP.to_s
    end

    if otp_verified
      if @user.update(phone: session.delete(:pending_phone), country_code: session.delete(:pending_country_code))
        flash[:success] = I18n.t('user_settings.phone_updated')
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to user_settings_path }
        end
      else
        session.delete(:pending_phone)
        session.delete(:pending_country_code)
        @error = @user.errors.full_messages.first
        render :verify_phone_number, status: :unprocessable_entity
      end
    else
      @error = I18n.t('user_settings.invalid_otp')
      render :verify_phone_number, status: :unprocessable_entity
    end
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
