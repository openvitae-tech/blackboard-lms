# frozen_string_literal: true

class PartnerOnboardingService
  include Singleton

  def create_partner(partner, team_management = TeamManagementService.instance)
    ActiveRecord::Base.transaction do
      success = partner.save
      return unless success

      success = team_management.create_team({ name: partner.name, parent_team_id: nil }, partner)

      unless success
        Rails.logger.info 'Partner creation failed - failed to create default team'
        raise ActiveRecord::Rollback
      end

      'ok'
    end
  end
end
