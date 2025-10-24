# frozen_string_literal: true

module Impersonations
  class FindOrCreateSupportUserService
    include Singleton

    def find_or_create_user(learning_partner)
      support_user = learning_partner.users.find_by(role: 'support')
      return support_user if support_user.present?

      generated_password = password
      support_user = User.new(
        name: "#{learning_partner.name} Support",
        role: 'support',
        email: support_email(learning_partner.name),
        password: generated_password,
        password_confirmation: generated_password,
        learning_partner:,
        team_id: learning_partner.parent_team.id,
        state: 'active'
      )
      support_user.skip_confirmation!
      support_user.save!

      support_user
    end

    private

    def support_email(name)
      formatted_name = name.downcase.gsub(/\s+/, '')
      "support@#{formatted_name}.com"
    end

    def password
      SecureRandom.hex(8)
    end
  end
end
