# frozen_string_literal: true
#
module UserOnboarding
  extend ActiveSupport::Concern

  included do
    before_action :proceed_to_onboarding_steps, if: :pending_onboarding?

    private

    def proceed_to_onboarding_steps
      redirect_to new_onboarding_welcome_path
    end

    def pending_onboarding?
      user_signed_in? && current_user.verified?
    end
  end
end