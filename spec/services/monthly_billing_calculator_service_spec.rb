# frozen_string_literal: true

RSpec.describe MonthlyBillingCalculatorService do
  let(:learning_partner_one) { create :learning_partner }
  let(:learning_partner_two) { create :learning_partner }
  let(:team) { create :team, learning_partner: learning_partner_one }

  before do
    @manager = create :user, :manager, team:, learning_partner: learning_partner_one
    @learner_one = create :user, :learner, team:, learning_partner: learning_partner_one
    @learner_two = create :user, :learner, team:, learning_partner: learning_partner_one
    @learner_three = create :user, :learner, team:, learning_partner: learning_partner_two
  end

  describe '#process_learning_partners' do
    it 'bills full month for a continuously active user' do
      travel_to Time.utc(2025, 2, 1)
      create(:event, name: 'user_activated', user_id: @manager.id, partner_id: learning_partner_one.id,
                     created_at: 2.months.ago.beginning_of_month,
                     data: { 'target_user_id' => @learner_one.id })
      create(:event, name: 'user_activated', user_id: @manager.id, partner_id: learning_partner_one.id,
                     created_at: 3.months.ago.beginning_of_month,
                     data: { 'target_user_id' => @learner_two.id })

      described_class.new.process
      payment = Payment.find_by!(learning_partner_id: learning_partner_one.id)
      days_in_jan = '62'

      expect(payment.billable_days).to eq(days_in_jan)
    end
  end
end
