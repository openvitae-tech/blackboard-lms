# frozen_string_literal: true

FactoryBot.define do
  factory :invoice do
    transient do
      users_count { learning_partner.users.count || 0 }
    end

    billable_days { users_count * Time.zone.now.last_month.end_of_month.day }
    amount { Invoice::PER_DAY_RATE * billable_days }
    bill_date { Time.zone.now.last_month.end_of_month }
    active_users { users_count }

    learning_partner
  end
end
