class Invoice < ApplicationRecord

  PER_DAY_RATE = 100.00

  enum status: { pending: "pending", complete: "complete" }, _default: :pending

  before_validation :set_invoice_id, on: :create

  validates :billable_days, :amount, :bill_date, :status, :active_users, presence: true
  validates :invoice_id, presence: true, uniqueness: true

  belongs_to :learning_partner

  private

  def set_invoice_id
    last_invoice_id = Invoice.maximum(:invoice_id) || 100000
    self.invoice_id = last_invoice_id + 1
  end
end
