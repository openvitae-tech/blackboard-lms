# frozen_string_literal: true

class UserManagementService
  include Singleton

  def invite(invited_by_user, params, team)
    user = User.new(
      name: params[:name],
      email: params[:email],
      role: params[:role],
      team:,
      learning_partner_id: team.learning_partner_id
    )

    user.set_temp_password

    if user.save
      EVENT_LOGGER.publish_user_invited(invited_by_user, user)
    end

    user
  end

  def bulk_invite(invited_by_user, records, role, team)
    records.each do |name, email|
      invite(invited_by_user, { name:, email: , role: }, team)
    end
  end
end
