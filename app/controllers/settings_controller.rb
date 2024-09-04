class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_learning_partner
  def edit
    authorize :settings
  end
  def update
    authorize :settings
    current_user.update(profile_params)
    @notice = "Profile updated" if current_user.update(profile_params)
  end

  def update_password
    authorize :settings
    current_user.password = current_user.password_confirmation = password_params[:password]
    @notice = "Password updated"  if current_user.save
  end

  def team
    authorize :settings

    @learning_partner = current_user.learning_partner

    if current_user.is_admin?
      @members = User.where(role: "admin")
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
    params.require(:user).permit(:password)
  end

  def set_learning_partner
    if current_user.is_admin?
      @learning_partner = nil
    else
      @learning_partner = current_user.learning_partner
    end
  end
end