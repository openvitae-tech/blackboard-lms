# frozen_string_literal: true

module UserState
  extend ActiveSupport::Concern

  included do
    USER_STATES = %w[unverified verified active in-active]

    def unverified?
      self.state == 'unverified'
    end

    def verified?
      self.state == 'verified'
    end

    def active?
      state == 'active'
    end

    def deactivated?
      state == 'in-active'
    end

    def verify!
      raise Errors::IllegalUserState.new("User state #{self.state} can't switch to verify state") unless unverified?
      self.state = 'verified'
      self.save
    end

    def activate
      raise Errors::IllegalUserState.new("User state #{self.state} can't switch to active state") unless verified? || deactivated?
      self.state = 'active'
      self.save
    end

    def deactivate
      raise Errors::IllegalUserState.new("User state #{self.state} can't switch to deactivate state") unless active?
      self.state = 'in-active'
      self.save
    end
  end

  class_methods do
  end
end