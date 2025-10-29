# frozen_string_literal: true

class Result < BaseResult
  attr_reader :status, :data

  def initialize(status, data)
    super()
    @status = status
    @data = data
  end

  def ok?
    status == :ok
  end

  def self.ok(data = nil)
    new(:ok, data)
  end

  def self.error(data = nil)
    new(:error, data)
  end
end
