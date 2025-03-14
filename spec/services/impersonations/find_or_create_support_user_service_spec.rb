# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Impersonations::FindOrCreateSupportUserService do
  subject { described_class.instance }

  before do
    @team = create :team
  end

  describe '#find_or_create_user' do
    it 'returns support user if already present' do
      @support_user = create :user, role: 'support', team: @team, learning_partner: @team.learning_partner
      expect do
        service_response = subject.find_or_create_user(@team.learning_partner)
        expect(service_response).to eq(@support_user)
      end.not_to change(User, :count)
    end

    it 'create support user if not present' do
      expect do
        subject.find_or_create_user(@team.learning_partner)
      end.to change(User, :count).by(1)
    end
  end
end
