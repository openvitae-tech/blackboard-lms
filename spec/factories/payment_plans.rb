# frozen_string_literal: true

FactoryBot.define do
  factory :payment_plan, class: 'PaymentPlan' do
    start_date { Time.zone.now }
    end_date { 1.month.from_now }
    total_seats { 30 }
    per_seat_cost { 500 }
  end
end
