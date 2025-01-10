# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    super do |resource|
      if resource.errors.empty?
        resource.activate
        EVENT_LOGGER.publish_user_joined(resource)
        EVENT_LOGGER.publish_active_user_count(resource)

        if resource.is_owner?

          partner = resource.learning_partner

          unless partner.first_owner_joined
            service = PartnerOnboardingService.instance
            service.first_owner_joined(partner, resource)
          end
        end
      end
    end
  end
end
