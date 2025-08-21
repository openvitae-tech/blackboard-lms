# frozen_string_literal: true

class MobileNumber
  include ActiveModel::API

  attr_accessor :value

  validates :value, numericality: true, length: { minimum: 10, maximum: 10 }
end
