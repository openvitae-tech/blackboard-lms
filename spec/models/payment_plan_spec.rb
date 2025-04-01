# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentPlan, type: :model do
  let(:learning_partner) { create :learning_partner }
  let(:payment_plan) { create :payment_plan, learning_partner: }

  describe '#start_date' do
    it 'is not valid without start_date' do
      payment_plan.start_date = ''

      expect(payment_plan).not_to be_valid
      expect(payment_plan.errors.full_messages.to_sentence).to eq(t('cant_blank',
                                                                    field: 'Start date'))
    end
  end

  describe '#end_date' do
    it 'is not valid without end_date' do
      payment_plan.end_date = ''

      expect(payment_plan).not_to be_valid
      expect(payment_plan.errors.full_messages.to_sentence).to eq(t('cant_blank',
                                                                    field: 'End date'))
    end

    it 'ensures end_date is after start_date' do
      payment_plan.start_date = Time.zone.today
      payment_plan.end_date = Time.zone.today - 1.day

      expect(payment_plan).not_to be_valid
      expect(payment_plan.errors.full_messages.to_sentence).to eq('End date must be greater than start date')
    end
  end

  describe '#per_seat_cost' do
    it 'is not valid without per_seat_cost' do
      payment_plan.per_seat_cost = ''

      expect(payment_plan).not_to be_valid
      expect(payment_plan.errors.full_messages.to_sentence).to eq(t('cant_blank',
                                                                    field: 'Per seat cost'))
    end
  end

  describe '#total_seats' do
    it 'is not valid without total_seats' do
      payment_plan.total_seats = ''

      expect(payment_plan).not_to be_valid
      expect(payment_plan.errors.full_messages.to_sentence).to include(t('cant_blank',
                                                                         field: 'Total seats'))
    end

    it 'must be a number' do
      payment_plan.total_seats = 'abc'

      expect(payment_plan).not_to be_valid
      expect(payment_plan.errors.full_messages.to_sentence).to eq('Total seats is not a number')
    end
  end

  describe '#acceptable_total_seats_count' do
    before do
      learning_partner.update!(users_count: 5)
    end

    it 'ensures total_seats is not less than the number of active users' do
      payment_plan.total_seats = 4

      expect(payment_plan).not_to be_valid
      expect(payment_plan.errors.full_messages.to_sentence)
        .to eq("Total seats cannot be less than the actual number of users (#{learning_partner.users_count}).")
    end
  end

  describe '#assign_defaults' do
    it 'assigns default total_seats' do
      new_plan = described_class.new
      expect(new_plan.total_seats).to eq(PaymentPlan::DEFAULT_TOTAL_SEATS)
    end
  end

  describe '.default_plan' do
    it 'returns a new instance with default dates' do
      default_plan = described_class.default_plan
      expect(default_plan.start_date).to eq(Time.zone.today)
      expect(default_plan.end_date).to eq(Time.zone.today + 1.month)
    end
  end
end
