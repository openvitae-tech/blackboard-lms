class MonthlyInvoiceCalculatorJob < BaseJob
  def perform
    billing_month = Time.zone.now.last_month

    MonthlyInvoiceCalculatorService.new(billing_month).process
  end
end
