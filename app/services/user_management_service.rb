# frozen_string_literal: true

class UserManagementService
  include Singleton

  def invite(invited_by_user, email, role, team)
    user = User.new(email:, role:, team:, learning_partner_id: team.learning_partner_id)
    user.set_temp_password

    if user.save
      EVENT_LOGGER.publish_user_invited(invited_by_user, user)
    end

    user
  end

  def bulk_invite(invited_by_user, emails, role, team)
    emails.each do
      invite(invited_by_user, email, role, team)
    end
  end
end
