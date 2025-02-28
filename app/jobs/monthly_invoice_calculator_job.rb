class MonthlyInvoiceCalculatorJob < BaseJob
  def perform
    billing_month = Time.zone.now.last_month

    LearningPartner.find_each(batch_size: 10) do |learning_partner|
      MonthlyInvoiceCalculatorService.new(billing_month, [learning_partner]).process
    end

    NotificationService.notify(
      User.where(role: "admin").last,
      t("invoice.notification.title"), t("invoice.notification.description", month: billing_month.strftime("%B")))
  end
end
