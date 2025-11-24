# frozen_string_literal: true

class PartnerOnboardingService
  include Singleton

  def new_cache_key
    "new-learning-partner-#{SecureRandom.uuid}"
  end

  def save_step(cache_key, step, params)
    data = Rails.cache.read(cache_key) || {}

    case step
    when 1 then create_step1(cache_key, data, params)
    when 2 then create_step2(cache_key, data, params)
    end
  end

  def load_step(cache_key, step)
    save_step(cache_key, step, {})
  end

  def create_step1(cache_key, data, params)
    partner = LearningPartner.new
    partner.name = params[:name] || data[:name]
    partner.about = params[:about] || data[:about]
    # As of now single supported country is passed from the frontend, this field
    # supported_countries is kept as an array for future scope when the platform
    # has to support multiple countries.
    supported_countries = params[:supported_countries].nil? ? (data[:supported_countries] || []) : [params[:supported_countries]]
    partner.supported_countries = supported_countries

    data[:name] = partner.name
    data[:about] = partner.about
    data[:supported_countries] = partner.supported_countries

    Rails.cache.write(cache_key, data, expires_in: 1.minute)

    if partner.valid?
      Result.ok(partner)
    else
      Result.error(partner)
    end
  end

  def create_step2(cache_key, data, params)
    partner = create_step1(cache_key, data, params).data

    partner.logo = params[:logo] || data[:logo]
    partner.banner = params[:banner] || data[:banner]

    data[:logo] = partner.logo
    data[:banner] = partner.banner

    Rails.cache.write(cache_key, data, expires_in: 1.minute)

    if partner.valid?
      Result.ok(partner)
    else
      Result.error(partner)
    end
  end

  def create_partner(partner, team_management = TeamManagementService.instance)
    ActiveRecord::Base.transaction do
      success = partner.save

      return Result.error(partner) unless success

      team = Team.new(name: partner.name)

      success = team_management.create_team(team, partner)

      unless success
        Rails.logger.info 'Partner creation failed - failed to create default team'
        raise ActiveRecord::Rollback
      end

      Result.ok(partner)
    end
  end

  def first_owner_joined(partner, user)
    partner.update(first_owner_joined: true)
    EVENT_LOGGER.publish_first_user_joined(user, partner)
  end
end
