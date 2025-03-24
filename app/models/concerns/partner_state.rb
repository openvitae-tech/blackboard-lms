# frozen_string_literal: true

module PartnerState
  extend ActiveSupport::Concern

  PARTNER_STATES = %w[new in-active].freeze

  included do
    validates :state, presence: true, inclusion: { in: PARTNER_STATES }

    def active?
      # considering new partners as active by default
      state == 'new'
    end

    def deactivated?
      state == 'in-active'
    end

    def activate
      raise Errors::IllegalPartnerState, "User state #{state} can't switch to in-active state" unless deactivated?

      self.state = 'new'
      save
    end

    def deactivate
      raise Errors::IllegalPartnerState, "User state #{state} can't switch to in-active state" unless active?

      self.state = 'in-active'
      save
    end
  end
end
