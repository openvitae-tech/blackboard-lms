# frozen_string_literal: true

module PartnerState
  extend ActiveSupport::Concern

  included do
    PARTNER_STATES = %w[new in-active]

    validates :state, presence: true, inclusion: { in: PARTNER_STATES }

    def active?
      # considering new partners as active by default
      state == 'new'
    end

    def deactivated?
      state == 'in-active'
    end

    def activate
      if deactivated?
        self.state = 'new'
        self.save
      else
        raise Errors::IllegalPartnerState.new("User state #{self.state} can't switch to in-active state")
      end
    end

    def deactivate
      if active?
        self.state = 'in-active'
        self.save
      else
        raise Errors::IllegalPartnerState.new("User state #{self.state} can't switch to in-active state")
      end
    end
  end

  class_methods do
  end
end