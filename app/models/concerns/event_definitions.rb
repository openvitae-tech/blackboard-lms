# frozen_string_literal: true

module EventDefinitions
  extend ActiveSupport::Concern

  included do
    # event definitions
    OnboardingInitiated = Struct.new(:partner_name, :partner_id, keyword_init: true)
    OnboardingCompleted = Struct.new(:partner_name, :partner_id, :email, keyword_init: true)
  end

  class_methods do
  end
end
