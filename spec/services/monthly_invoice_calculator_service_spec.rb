# frozen_string_literal: true

RSpec.describe MonthlyInvoiceCalculatorService do
  let(:learning_partner_one) { create :learning_partner }
  let(:learning_partner_two) { create :learning_partner }
  let(:team) { create :team, learning_partner: learning_partner_one }

  before do
    @manager_one = create :user, :manager, team:, learning_partner: learning_partner_one
    @manager_two = create :user, :manager, team:, learning_partner: learning_partner_two

    @learner_one = create :user, :learner, team:, learning_partner: learning_partner_one
    @learner_two = create :user, :learner, team:, learning_partner: learning_partner_one
    @learner_three = create :user, :learner, team:, learning_partner: learning_partner_two
  end

  describe '#process_learning_partners' do
    before do
      travel_to Time.utc(2025, 2, 1)

      Invoice.create!(billable_days: 93,
                      amount: 93 * Invoice::PER_DAY_RATE, active_users: 3,
                      bill_date: 2.months.ago.beginning_of_month, learning_partner: learning_partner_one)

      publish_user_activated(@manager_one, @learner_one, 2.months.ago.beginning_of_month)
      publish_user_activated(@manager_one, @learner_two, 3.months.ago.beginning_of_month)
    end

    it 'bills full month for continuously active users for learning partners' do
      Invoice.create!(billable_days: 31,
                      amount: 31 * Invoice::PER_DAY_RATE, active_users: 1,
                      bill_date: 2.months.ago.beginning_of_month, learning_partner: learning_partner_two)

      described_class.new(Time.zone.now.last_month, [learning_partner_one, learning_partner_two]).process
      partner_one_invoice = billing_month_invoice(learning_partner_one)
      partner_two_invoice = billing_month_invoice(learning_partner_two)
      partner_one_billable_days_in_jan = 93
      partner_two_billable_days_in_jan = 31

      expect(partner_one_invoice.billable_days).to eq(partner_one_billable_days_in_jan)
      expect(partner_two_invoice.billable_days).to eq(partner_two_billable_days_in_jan)

      expect(partner_one_invoice.amount.to_f).to eq(partner_one_billable_days_in_jan * Invoice::PER_DAY_RATE)
      expect(partner_two_invoice.amount.to_f).to eq(partner_two_billable_days_in_jan * Invoice::PER_DAY_RATE)

      expect(partner_one_invoice.active_users).to eq(3)
      expect(partner_two_invoice.active_users).to eq(1)
    end

    it 'calculate invoice for a new learning partner onboarded during the billing month' do
      publish_user_activated(@manager_two, @learner_three, Time.utc(2025, 1, 2))
      publish_user_deactivated(@manager_two, @learner_three, Time.utc(2025, 1, 10))

      LearningPartner.find_each do |learning_partner|
        described_class.new(Time.zone.now.last_month, [learning_partner]).process
      end
      invoice = billing_month_invoice(learning_partner_two)
      billable_days_in_jan = 8
      expect(invoice.billable_days).to eq(billable_days_in_jan)
      expect(invoice.active_users).to eq(0)
    end

    it 'multiple users got deactivated during the billing month' do
      publish_user_deactivated(@manager_one, @learner_two, Time.utc(2025, 1, 10))
      publish_user_deactivated(@manager_one, @learner_one, Time.utc(2025, 1, 20))
      LearningPartner.find_each do |learning_partner|
        described_class.new(Time.zone.now.last_month, [learning_partner]).process
      end

      invoice = billing_month_invoice(learning_partner_one)
      billable_days_in_jan = 59
      expect(invoice.billable_days).to eq(billable_days_in_jan)
      expect(invoice.active_users).to eq(1)
      expect(invoice.amount.to_f).to eq(billable_days_in_jan * Invoice::PER_DAY_RATE)
    end

    it 'multiple users got deactivated and activated multiple times during the billing month' do
      publish_user_deactivated(@manager_one, @learner_one, Time.utc(2025, 1, 10))
      publish_user_activated(@manager_one, @learner_one, Time.utc(2025, 1, 15))
      publish_user_deactivated(@manager_one, @learner_two, Time.utc(2025, 1, 8))
      publish_user_activated(@manager_one, @learner_two, Time.utc(2025, 1, 15))
      LearningPartner.find_each do |learning_partner|
        described_class.new(Time.zone.now.last_month, [learning_partner]).process
      end

      invoice = billing_month_invoice(learning_partner_one)
      billable_days_in_jan = 81

      expect(invoice.billable_days).to eq(billable_days_in_jan)
      expect(invoice.active_users).to eq(3)
      expect(invoice.amount.to_f).to eq(billable_days_in_jan * Invoice::PER_DAY_RATE)
    end

    it 'user got deactivated and activated multiple times during the billing month' do
      publish_user_deactivated(@manager_one, @learner_one, Time.utc(2025, 1, 10))
      publish_user_activated(@manager_one, @learner_one, Time.utc(2025, 1, 15))
      publish_user_deactivated(@manager_one, @learner_one, Time.utc(2025, 1, 20))
      LearningPartner.find_each do |learning_partner|
        described_class.new(Time.zone.now.last_month, [learning_partner]).process
      end

      invoice = billing_month_invoice(learning_partner_one)
      billable_days_in_jan = 76
      expect(invoice.billable_days).to eq(billable_days_in_jan)
      expect(invoice.active_users).to eq(2)
      expect(invoice.amount.to_f).to eq(billable_days_in_jan * Invoice::PER_DAY_RATE)
    end

    it 'new user got added to the existing learning partner during the billing month' do
      new_learner = create :user, :learner, team:, learning_partner: learning_partner_one
      publish_user_activated(@manager_one, new_learner, Time.utc(2025, 1, 8))
      LearningPartner.find_each do |learning_partner|
        described_class.new(Time.zone.now.last_month, [learning_partner]).process
      end

      invoice = billing_month_invoice(learning_partner_one)
      billable_days_in_jan = 117
      expect(invoice.billable_days).to eq(billable_days_in_jan)
      expect(invoice.active_users).to eq(4)
      expect(invoice.amount.to_f).to eq(billable_days_in_jan * Invoice::PER_DAY_RATE)
    end

    it 'previous month deactivated user got activated during the billing month' do
      publish_user_deactivated(@manager_one, @learner_two, Time.utc(2024, 12, 31))
      Invoice.first.update!(active_users: 2)
      publish_user_activated(@manager_one, @learner_two, Time.utc(2025, 1, 11))

      LearningPartner.find_each do |learning_partner|
        described_class.new(Time.zone.now.last_month, [learning_partner]).process
      end
      invoice = billing_month_invoice(learning_partner_one)
      billable_days_in_jan = 83

      expect(invoice.billable_days).to eq(billable_days_in_jan)
      expect(invoice.active_users).to eq(3)
      expect(invoice.amount.to_f).to eq(billable_days_in_jan * Invoice::PER_DAY_RATE)
    end

    it 'user got activated and deactivated the same day during the billing month' do
      publish_user_activated(@manager_two, @learner_three, Time.utc(2025, 1, 10))
      publish_user_deactivated(@manager_two, @learner_three, Time.utc(2025, 1, 10))
      LearningPartner.find_each do |learning_partner|
        described_class.new(Time.zone.now.last_month, [learning_partner]).process
      end

      invoice = billing_month_invoice(learning_partner_two)
      billable_days_in_jan = 0

      expect(invoice.billable_days).to eq(billable_days_in_jan)
      expect(invoice.active_users).to eq(0)
      expect(invoice.amount.to_f).to eq(billable_days_in_jan * Invoice::PER_DAY_RATE)
    end

    it 'ignores consecutive duplicate events' do
      publish_user_activated(@manager_two, @learner_three, Time.utc(2025, 1, 13))
      publish_user_activated(@manager_two, @learner_three, Time.utc(2025, 1, 16))
      publish_user_deactivated(@manager_two, @learner_three, Time.utc(2025, 1, 20))
      publish_user_deactivated(@manager_two, @learner_three, Time.utc(2025, 1, 25))

      LearningPartner.find_each do |learning_partner|
        described_class.new(Time.zone.now.last_month, [learning_partner]).process
      end

      invoice = billing_month_invoice(learning_partner_two)
      billable_days_in_jan = 7

      expect(invoice.billable_days).to eq(billable_days_in_jan)
      expect(invoice.active_users).to eq(0)
      expect(invoice.amount.to_f).to eq(billable_days_in_jan * Invoice::PER_DAY_RATE)
    end

    it 'ensures invoice remains unchanged when recalculated for the same learning partner' do
      publish_user_activated(@manager_two, @learner_three, Time.utc(2025, 1, 13))
      publish_user_deactivated(@manager_two, @learner_three, Time.utc(2025, 1, 20))

      LearningPartner.find_each do |learning_partner|
        described_class.new(Time.zone.now.last_month, [learning_partner]).process
      end

      invoice = billing_month_invoice(learning_partner_two)
      billable_days_in_jan = 7

      expect(invoice.billable_days).to eq(billable_days_in_jan)
      expect(invoice.active_users).to eq(0)
      expect(invoice.amount.to_f).to eq(billable_days_in_jan * Invoice::PER_DAY_RATE)

      LearningPartner.find_each do |learning_partner|
        described_class.new(Time.zone.now.last_month, [learning_partner]).process
      end

      expect(invoice.billable_days).to eq(billable_days_in_jan)
      expect(invoice.active_users).to eq(0)
      expect(invoice.amount.to_f).to eq(billable_days_in_jan * Invoice::PER_DAY_RATE)
    end
  end

  private

  def billing_month_invoice(learning_partner)
    Invoice.where(learning_partner:)
           .where(bill_date: Time.zone.now.last_month.end_of_month)
           .order(:bill_date)
           .last
  end

  def publish_user_activated(manager, user, jump_time)
    travel_to jump_time do
      EVENT_LOGGER.publish_user_activated(manager, user)
    end
  end

  def publish_user_deactivated(manager, user, jump_time)
    travel_to jump_time do
      EVENT_LOGGER.publish_user_deactivated(manager, user)
    end
  end
end
