# frozen_string_literal: true

class ClassroomKit < ApplicationRecord
  belongs_to :learning_partner
  has_many :classroom_kit_components, dependent: :destroy

  validates :neo_ai_kit_id, presence: true, uniqueness: true
end
