# frozen_string_literal: true

class ContactLead < ApplicationRecord
  validates :phone, presence: true
  validates :country_code, presence: true
  validates :name, presence: true
end
