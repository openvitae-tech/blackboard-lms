# frozen_string_literal: true

module UsersHelper
  def role_text(role)
    User::USER_ROLE_MAPPING[role.to_sym]
  end

  def org_name(partner)
    partner && partner.name.present? ? partner.name : Rails.application.credentials.org_name
  end

  def user_role_mapping
    User::USER_ROLE_MAPPING.invert
  end

  def user_role_mapping_for_partner(current_user, team)
    mapping = User::USER_ROLE_MAPPING.dup
    mapping.delete(:admin)
    mapping.delete(:owner) if current_user.is_manager?
    mapping.delete(:owner) unless team.parent_team?
    mapping.invert
  end

  def invite_status(user)
    user.confirmed_at ? 'Verified' : 'Invited'
  end

  def user_verified?(user)
    user.confirmed_at.present?
  end

  def user_name(user)
    ActiveSupport::Deprecation.warn(
      "UsersHelper#user_name is deprecated. " \
        "Use User#display_name instead."
    )
    user.name.blank? ? role_text(user.role) : user.name.split.first
  end

  def user_avatar(user)
    user_name(user)[0]&.upcase
  end
end
