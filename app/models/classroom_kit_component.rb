# frozen_string_literal: true

class ClassroomKitComponent < ApplicationRecord
  belongs_to :classroom_kit

  validates :neo_ai_component_id, :component_type, presence: true
end
