# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NeoAi::ClassroomKitSaveService do
  let(:neo_ai) { instance_double(NeoAi::Client) }
  let(:service) { described_class.new(neo_ai) }
  let(:learning_partner) { create(:learning_partner) }
  let(:neo_ai_data) do
    {
      'id' => 'kit-123',
      'title' => 'Leadership Fundamentals',
      'status' => 'COMPLETED',
      'components' => [
        { 'id' => 'comp-1', 'type' => 'slide_deck', 'title' => 'Slide deck for learners', 'status' => 'READY',
          'download_url' => 'https://s3.example.com/slide.pptx' },
        { 'id' => 'comp-2', 'type' => 'trainer_guide', 'title' => 'Trainer guide', 'status' => 'READY',
          'download_url' => 'https://s3.example.com/guide.docx' }
      ]
    }
  end

  before do
    allow(neo_ai).to receive(:get_kit).with('kit-123').and_return(neo_ai_data)
  end

  describe '#call — initial save' do
    it 'creates a ClassroomKit with the correct attributes' do
      kit = service.call('kit-123', learning_partner_id: learning_partner.id)
      expect(kit.neo_ai_kit_id).to eq('kit-123')
      expect(kit.title).to eq('Leadership Fundamentals')
      expect(kit.learning_partner_id).to eq(learning_partner.id)
    end

    it 'creates ClassroomKitComponents for each component' do
      kit = service.call('kit-123', learning_partner_id: learning_partner.id)
      expect(kit.classroom_kit_components.count).to eq(2)
    end

    it 'maps component type and title correctly' do
      kit = service.call('kit-123', learning_partner_id: learning_partner.id)
      slide = kit.classroom_kit_components.find_by(neo_ai_component_id: 'comp-1')
      expect(slide.component_type).to eq('slide_deck')
      expect(slide.title).to eq('Slide deck for learners')
    end

    it 'prefers the cached title over the NeoAi title when present' do
      allow(Rails.cache).to receive(:read).with('kit_title_kit-123').and_return('Custom Title')
      kit = service.call('kit-123', learning_partner_id: learning_partner.id)
      expect(kit.title).to eq('Custom Title')
    end
  end

  describe '#call — idempotent re-save' do
    it 'updates the existing kit and components without duplicating' do
      service.call('kit-123', learning_partner_id: learning_partner.id)
      expect { service.call('kit-123', learning_partner_id: learning_partner.id) }
        .not_to change(ClassroomKit, :count)
    end

    it 'does not duplicate components on re-save' do
      service.call('kit-123', learning_partner_id: learning_partner.id)
      expect { service.call('kit-123', learning_partner_id: learning_partner.id) }
        .not_to change(ClassroomKitComponent, :count)
    end
  end
end
