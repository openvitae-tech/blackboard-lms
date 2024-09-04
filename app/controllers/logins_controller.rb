class LoginsController < ApplicationController

  layout 'devise'
  def new
  end

  def otp
    @mobile_number = params[:mobile_number]
    user_exists = User.exists?(phone: @mobile_number)

    if user_exists
      user = User.where(phone: @mobile_number).last
      user.set_otp!
    else
      redirect_to new_login_path,  notice: "Incorrect mobile number"
    end
  end
  def create
    user_exists = User.exists?(phone: login_params[:mobile_number])

    if user_exists
      user = User.where(phone: login_params[:mobile_number]).last

      if user.otp_generated_at > 5.minute.ago && user.otp.to_s == login_params[:otp]
        build_user_session!(user)
        redirect_to after_sign_in_path_for(user)
      else
        redirect_to new_login_path,  notice: "Incorrect otp or otp expired"
      end
    else
      redirect_to new_login_path,  notice: "Incorrect mobile number or otp"
    end
  end

  private

  def login_params
    params.require(:login).permit(:mobile_number, :otp)
  end

  def build_user_session!(user)
    sign_in user
  end
end