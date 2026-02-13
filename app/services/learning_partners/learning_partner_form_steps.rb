# frozen_string_literal: true

module LearningPartners
  class LearningPartnerFormSteps
    STEP_ONE   = 1
    STEP_TWO   = 2
    STEP_THREE = 3

    STEP_ONE_FIELDS = %i[name about supported_countries organisation_type].freeze
    STEP_TWO_FIELDS = %i[logo banner].freeze

    def self.error_step_for(learning_partner)
      return STEP_ONE if step_one_error?(learning_partner)
      return STEP_TWO if step_two_error?(learning_partner)
      return STEP_THREE if payment_plan_error?(learning_partner)

      STEP_ONE
    end

    class << self
      private

      def step_one_error?(learning_partner)
        STEP_ONE_FIELDS.any? { |field| learning_partner.errors.key?(field) }
      end

      def step_two_error?(learning_partner)
        STEP_TWO_FIELDS.any? { |field| learning_partner.errors.key?(field) }
      end

      def payment_plan_error?(learning_partner)
        learning_partner.payment_plan&.errors&.any?
      end
    end
  end
end
