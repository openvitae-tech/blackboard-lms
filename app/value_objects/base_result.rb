# frozen_string_literal: true

class BaseResult
  attr_reader :status, :data

  def initialize
    raise 'Cannot initialize an abstract BaseResult class' if instance_of?(BaseResult)
  end

  def ok?
    raise NotImplementedError, "#{self.class.name} must implement #{__method__} method."
  end

  def self.ok(data = nil)
    raise NotImplementedError, "#{self.class.name} must implement #{__method__} method."
  end

  def self.error(data = nil)
    raise NotImplementedError, "#{self.class.name} must implement #{__method__} method."
  end
end
