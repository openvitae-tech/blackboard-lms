class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_learning_partner
  def edit
    authorize :settings
  end
  def update
    authorize :settings

    if current_user.update(profile_params)
      redirect_to edit_settings_path, notice: "Profile updated"
    else
      redirect_to edit_settings_path
    end
  end

  def update_password
    authorize :settings

    current_user.password = current_user.password_confirmation = password_params[:password]

    if current_user.save
      redirect_to edit_settings_path, notice: "Password updated"
    else
      redirect_to edit_settings_path
    end
  end

  def team
    authorize :settings

    if current_user.is_admin?
      @members = User.where(role: "admin")
    else
      @members = current_user.learning_partner.users
    end
  end

  def invite_admin
    authorize :user

    user = UserManagementService.instance.invite(invite_admin_params[:email], "admin", nil)

    if user.save
      redirect_to team_settings_path, notice: "Invitation sent to user"
    else
      render :team, status: :unprocessable_entity
    end
  end

  def invite_member
    authorize :user

    partner = if current_user.is_admin?
                LearningPartner.find(invite_member_params[:learning_partner_id])
              else
                @learning_partner
              end

    user = UserManagementService.instance.invite(invite_member_params[:email],
                                                 invite_member_params[:role], partner)

    if user.save
      redirect_to request.referer, notice: "Invitation sent to user"
    else
      render :team, status: :unprocessable_entity
    end
  end

  def resend_invitation
    user = User.find(params[:user_id])
    authorize user
    user.set_temp_password
    user.save!
    user.send_confirmation_instructions
    redirect_to request.referer, notice: "Invitation sent to user"
  end

  private

  def profile_params
    params.require(:user).permit(:name, :phone)
  end

  def password_params
    params.require(:user).permit(:password)
  end

  def invite_admin_params
    params.require(:user).permit(:email)
  end

  def invite_member_params
    params.require(:user).permit(:email, :role, :learning_partner_id)
  end

  def set_learning_partner
    if current_user.is_admin?
      @learning_partner = nil
    else
      @learning_partner = current_user.learning_partner
    end
  end
end