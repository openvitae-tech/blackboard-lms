# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserActivatedDeactivatedQuery do
  let(:learning_partner) { create :learning_partner }
  let(:team) { create :team, learning_partner: }

  before do
    @manager = create(:user, :manager, team:, learning_partner:)
    @learner = create(:user, :learner, team:, learning_partner:)

    EVENT_LOGGER.publish_user_activated(@manager, @learner)
    EVENT_LOGGER.publish_user_deactivated(@manager, @learner)
    EVENT_LOGGER.publish_onboarding_initiated(@learner, learning_partner)
  end

  describe '#call' do
    it 'list user activated and deactivated events' do
      events = Event.where(
        partner_id: learning_partner,
        created_at: Time.zone.now.all_month,
        name: %w[user_activated user_deactivated]
      )
      service = described_class.new(learning_partner.id, Time.zone.now.all_month).call

      expect(events.pluck(:id).sort).to eq(service.pluck(:id).sort)
    end
  end
end
