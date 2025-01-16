# frozen_string_literal: true

class UserManagementService
  include Singleton

  def invite(invited_by_user, params, team)
    raise_error_if_exceeds_user_limit!(team.learning_partner)

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

  def activate(manager, target_user)
    raise Errors::IllegalUserState.new("User state is illegal") unless target_user.deactivated?
    return false unless target_user.activate
    EVENT_LOGGER.publish_user_activated(manager, target_user)
    EVENT_LOGGER.publish_active_user_count(target_user)
    true
  end

  def deactivate(manager, target_user)
    raise Errors::IllegalUserState.new("User state is illegal") unless target_user.active?
    return false unless target_user.deactivate
    EVENT_LOGGER.publish_user_deactivated(manager, target_user)
    EVENT_LOGGER.publish_active_user_count(target_user)
    true
  end

  private

  def raise_error_if_exceeds_user_limit!(learning_partner)
    unless learning_partner.users_count < learning_partner.max_user_count
      raise Errors::IllegalInviteError.new(
        I18n.t('invite.exceeds_user_limit') % { limit: learning_partner.max_user_count }
      )
    end
  end
end
