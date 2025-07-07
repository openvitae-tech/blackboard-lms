# frozen_string_literal: true

module UserState
  extend ActiveSupport::Concern

  UNVERIFIED = 'unverified'
  VERIFIED = 'verified'
  ACTIVE = 'active'
  INACTIVE = 'in-active'

  USER_STATES = [UNVERIFIED, VERIFIED, ACTIVE, INACTIVE].freeze

  included do
    def unverified?
      state == UNVERIFIED
    end

    def verified?
      state == VERIFIED
    end

    def active?
      state == ACTIVE
    end

    def deactivated?
      state == INACTIVE
    end

    def verify!
      raise Errors::IllegalUserState, "User state #{state} can't switch to verify state" unless unverified?

      self.state = VERIFIED
      save
    end

    def activate
      unless verified? || deactivated?
        raise Errors::IllegalUserState, "User state #{state} can't switch to active state"
      end

      self.state = ACTIVE
      save
    end

    def deactivate
      raise Errors::IllegalUserState, "User state #{state} can't switch to deactivate state" unless active?

      self.state = INACTIVE
      save
    end
  end
end
