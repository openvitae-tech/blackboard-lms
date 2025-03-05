class Invoice < ApplicationRecord

  PER_DAY_RATE = 100.00

  enum status: { pending: "pending", complete: "complete" }, _default: :pending

  validates :billable_days, :amount, :bill_date, :status, :active_users, presence: true

  belongs_to :learning_partner
end
