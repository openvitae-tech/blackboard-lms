# frozen_string_literal: true

# Invites Controller is used to invite new  members by the manager or owners.
# This is not meant for inviting other admins.
class InvitesController < ApplicationController
  before_action :authenticate_user!
  def new
    authorize :invite
    @team = Team.find(params[:team_id])
    @user = User.new(team: @team)
  end

  def create
    service = UserManagementService.instance
    @team = Team.find(invite_params[:team_id])
    authorize @team, :create?, policy_class: InvitePolicy

    @bulk_invite = invite_params[:bulk_invite].present?

    status =
      if @bulk_invite
        # Bulk invite users as learners
        emails = process_bulk_invite(invite_params[:bulk_invite])
        service.bulk_invite(current_user, emails, :learner, @team)
        :ok
      else
        @user = service.invite(current_user, invite_params[:email], invite_params[:role], @team)
        @user.persisted? ? :ok : :error
      end

    if status == :ok
      flash.now[:success] = @bulk_invite ? I18n.t('invite.bulk') : I18n.t('invite.single')
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def resend
    user = User.where(id: params[:id], team_id: params[:team_id]).first

    if user.present?
      authorize user,:resend?, policy_class: InvitePolicy
      user.set_temp_password
      user.save!
      user.send_confirmation_instructions
      flash.now[:success] = "Invitation sent to #{user.email}"
    else
      flash.now[:error] = 'Failed to invite user, are you sure that this user exists ?'
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
    params.require(:user).permit(:email, :role, :team_id, :bulk_invite)
  end

  def invite_admin_params
    params.require(:user).permit(:email)
  end

  def process_bulk_invite(file_input)
    return [] unless file_input.respond_to? :read
    return [] unless file_input.content_type == 'text/csv' || file.content_type == 'text/plain'

    begin
      contents = file_input.read
      contents
        .split("\n")
        .map(&:strip).map(&:downcase)
        .filter { |email| User::EMAIL_REGEXP.match?(email) }
    rescue IOError => _e
      []
    end
  end
end
