# frozen_string_literal: true

class UserManagementService
  include Singleton

  def invite(invited_by_user, params, team)
    raise_error_if_exceeds_user_limit!(team.learning_partner)

    user = User.new(
      name: params[:name],
      phone: params[:phone],
      role: params[:role],
      team:,
      learning_partner_id: team.learning_partner_id
    )

    user.team = team.learning_partner.parent_team if user.is_owner? || user.is_support?
    user.set_temp_password

    if user.valid?
      user.save
      send_sms_invite(user)
      user.save!
      EVENT_LOGGER.publish_user_invited(invited_by_user, user)
    end

    user
  end

  def bulk_invite(invited_by_user, records, role, team)
    records.each do |name, phone|
      invite(invited_by_user, { name:, phone:, role: }, team)
    end
  end

  def activate(manager, target_user)
    raise Errors::IllegalUserState, 'User state is illegal' unless target_user.deactivated?
    return false unless target_user.activate

    EVENT_LOGGER.publish_user_activated(manager, target_user)
    EVENT_LOGGER.publish_active_user_count(target_user)
    true
  end

  def deactivate(manager, target_user)
    raise Errors::IllegalUserState, 'User state is illegal' unless target_user.active?
    return false unless target_user.deactivate

    EVENT_LOGGER.publish_user_deactivated(manager, target_user)
    EVENT_LOGGER.publish_active_user_count(target_user)
    true
  end

  def send_sms_invite(user)
    # this will reset the confirmation token
    user.reset_phone_confirmation_token
    user.phone_confirmation_sent_at = Time.current
    user.save!

    login_url = Rails.application.routes.url_helpers.new_login_url(host: Rails.application.credentials.dig(:app,
                                                                                                           :base_url))

    if Rails.env.local?
      Rails.logger.info "Hello, please click here to activate your Instruo account #{login_url}"
    else
      CommunicationChannels::SendSmsJob.perform_async(
        Rails.application.credentials.dig(:fast2sms, :template, :welcome), user.phone, login_url
      )
    end
  end

  # when user clicks the invite link sent to the phone
  def verify_user(user)
    user.verify!
    EVENT_LOGGER.publish_user_joined(user)

    return unless user.is_owner? && !user.learning_partner.first_owner_joined

    service = PartnerOnboardingService.instance
    service.first_owner_joined(partner, resource)
  end

  private

  def raise_error_if_exceeds_user_limit!(learning_partner)
    return if learning_partner.users_count < learning_partner.payment_plan.total_seats

    raise Errors::IllegalInviteError,
          format(I18n.t('invite.exceeds_user_limit'), limit: learning_partner.payment_plan.total_seats)
  end
end
