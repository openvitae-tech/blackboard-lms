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
        # user object is required in the form when there is an error
        @user = User.new(team: @team)
        # Bulk invite users as learners
        valid_records = BulkInviteInputService.instance.process(invite_params[:bulk_invite])

        if valid_records.present?
          service.bulk_invite(current_user, valid_records, :learner, @team)
          :ok
        else
          @user.errors.add(:base, I18n.t('invite.invalid_csv'))
          :error
        end
      else
        @user = service.invite(current_user, invite_params, @team)
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
      flash.now[:success] = format(I18n.t('invite.invite_sent'), email: user.email)
    else
      flash.now[:error] = I18n.t('invite.invalid_user')
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

  def download
    send_file(Rails.root.join("app/views/invites/learner_bulk_invite_sample.csv"), type: "text/csv", disposition: "inline")
  end

  private

  def invite_params
    params.require(:user).permit(:name, :email, :role, :team_id, :bulk_invite)
  end

  def invite_admin_params
    params.require(:user).permit(:email)
  end
end
