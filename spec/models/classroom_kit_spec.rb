# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClassroomKit, type: :model do
  let(:learning_partner) { create(:learning_partner) }

  describe 'associations' do
    it 'belongs to a learning_partner' do
      kit = build(:classroom_kit, learning_partner: learning_partner)
      expect(kit.learning_partner).to eq(learning_partner)
    end

    it 'has many classroom_kit_components, destroyed with the kit' do
      kit = create(:classroom_kit, learning_partner: learning_partner)
      create(:classroom_kit_component, classroom_kit: kit)
      expect { kit.destroy }.to change(ClassroomKitComponent, :count).by(-1)
    end
  end

  describe 'validations' do
    it 'is invalid without neo_ai_kit_id' do
      kit = build(:classroom_kit, learning_partner: learning_partner, neo_ai_kit_id: nil)
      expect(kit).not_to be_valid
    end

    it 'requires neo_ai_kit_id to be unique' do
      create(:classroom_kit, learning_partner: learning_partner, neo_ai_kit_id: 'kit-1')
      duplicate = build(:classroom_kit, learning_partner: learning_partner, neo_ai_kit_id: 'kit-1')
      expect(duplicate).not_to be_valid
    end
  end
end
