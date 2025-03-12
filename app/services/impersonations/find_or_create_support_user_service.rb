# frozen_string_literal: true

class Impersonations::FindOrCreateSupportUserService
  include Singleton

  def find_or_create_user(learning_partner)
    support_user = learning_partner.users.find_by(role: "support")
    if !support_user.present?
      support_user = User.create!(
        name: "#{learning_partner.name} Support",
        role: "support",
        email: support_email(learning_partner.name),
        password: Rails.application.credentials.dig(:support_user, :password),
        password_confirmation: Rails.application.credentials.dig(:support_user, :password),
        learning_partner:,
        team_id: learning_partner.parent_team.id,
        state: 'active'
      )
      support_user.confirm
    end
    support_user
  end

  private

  def support_email(name)
    formatted_name = name.downcase.gsub(/\s+/, '')
    "support@#{formatted_name}.com"
  end
end
