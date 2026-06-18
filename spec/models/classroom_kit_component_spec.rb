# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClassroomKitComponent, type: :model do
  let(:kit) { create(:classroom_kit) }

  describe 'associations' do
    it 'belongs to a classroom_kit' do
      component = build(:classroom_kit_component, classroom_kit: kit)
      expect(component.classroom_kit).to eq(kit)
    end
  end

  describe 'validations' do
    it 'is invalid without neo_ai_component_id' do
      component = build(:classroom_kit_component, classroom_kit: kit, neo_ai_component_id: nil)
      expect(component).not_to be_valid
    end

    it 'is invalid without component_type' do
      component = build(:classroom_kit_component, classroom_kit: kit, component_type: nil)
      expect(component).not_to be_valid
    end
  end
end
