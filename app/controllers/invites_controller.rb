# frozen_string_literal: true

# Invites Controller is used to invite new  members by the manager or owners.
# This is not meant for inviting other admins.
class InvitesController < ApplicationController
  before_action :authenticate_user!
  def new
    authorize :invite
    @team = Team.find(params[:team_id])
    @user = User.new
  end

  def create
    service = UserManagementService.instance
    @team = Team.find(invite_params[:team_id])
    authorize @team
    @user = service.invite(invite_params[:email], invite_params[:role], @team)

    if @user.save
      redirect_to request.referer, notice: 'Invitation sent to user'
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def resend
    user = User.where(id: params[:id], learning_partner_id: params[:learning_partner_id]).first
    authorize(user, :resend?, policy_class: InvitePolicy)

    if user.present?
      user.set_temp_password
      user.save!
      user.send_confirmation_instructions
      @message = "Invitation sent to #{user.email}"
    else
      @message = 'Failed to invite user, are you sure that this user exists ?'
    end
  end

  def new_admin
    authorize :invite
    @user = User.new
  end

  def create_admin
    authorize :invite

    @user = UserManagementService.instance.invite(invite_admin_params[:email], 'admin', nil)

    if @user.save
      redirect_to team_settings_path, notice: 'Invitation sent to user'
    else
      render :new_admin, status: :unprocessable_entity
    end
  end

  private

  def invite_params
    params.require(:user).permit(:email, :role, :team_id)
  end

  def invite_admin_params
    params.require(:user).permit(:email)
  end
end
