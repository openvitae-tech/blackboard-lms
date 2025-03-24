# frozen_string_literal: true

module UserState
  extend ActiveSupport::Concern

  USER_STATES = %w[unverified verified active in-active].freeze

  included do
    def unverified?
      state == 'unverified'
    end

    def verified?
      state == 'verified'
    end

    def active?
      state == 'active'
    end

    def deactivated?
      state == 'in-active'
    end

    def verify!
      raise Errors::IllegalUserState, "User state #{state} can't switch to verify state" unless unverified?

      self.state = 'verified'
      save
    end

    def activate
      unless verified? || deactivated?
        raise Errors::IllegalUserState, "User state #{state} can't switch to active state"
      end

      self.state = 'active'
      save
    end

    def deactivate
      raise Errors::IllegalUserState, "User state #{state} can't switch to deactivate state" unless active?

      self.state = 'in-active'
      save
    end
  end
end
