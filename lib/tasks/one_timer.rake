# frozen_string_literal: true

namespace :one_timer do
  desc 'Generate invoice for pre existing learning partners'
  task generate_invoice_for_pre_existing_partners: :environment do
    billing_month = Time.zone.now.last_month
    LearningPartner.find_each do |learning_partner|
      active_users = learning_partner.users.where(state: 'active').count
      Invoice.create!(billable_days: (billing_month.end_of_month.day * active_users), amount: 0.00,
                      bill_date: billing_month.end_of_month,
                      active_users:, learning_partner:)
    end
  end
end
