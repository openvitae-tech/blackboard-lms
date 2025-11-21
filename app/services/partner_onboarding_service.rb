# frozen_string_literal: true

class PartnerOnboardingService
  include Singleton

  def create_step1(params, team_management = TeamManagementService.instance)
    ActiveRecord::Base.transaction do
      partner = LearningPartner.new
      partner.name = params[:name]
      partner.about = params[:about]
      # As of now single supported country is passed from the frontend, this field
      # supported_countries is kept as an array for future scope when the platform
      # has to support multiple countries.
      partner.supported_countries = [params[:supported_countries]].compact

      return Result.error(partner) unless partner.save

      team = Team.new(name: partner.name)

      success = team_management.create_team(team, partner)

      unless success
        Rails.logger.info 'Partner creation failed - failed to create default team'
        raise ActiveRecord::Rollback
      end

      Result.ok(partner)
    end
  end

  def create_partner(partner, team_management = TeamManagementService.instance)
    ActiveRecord::Base.transaction do
      success = partner.save
      return unless success

      team = Team.new(name: partner.name)

      success = team_management.create_team(team, partner)

      unless success
        Rails.logger.info 'Partner creation failed - failed to create default team'
        raise ActiveRecord::Rollback
      end

      'ok'
    end
  end

  def first_owner_joined(partner, user)
    partner.update(first_owner_joined: true)
    EVENT_LOGGER.publish_first_user_joined(user, partner)
  end
end
