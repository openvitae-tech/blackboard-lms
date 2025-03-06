class MonthlyInvoiceCalculatorService
  attr_reader :billing_month, :learning_partners, :is_recalculation_needed

  def initialize(billing_month, learning_partners, is_recalculation_needed)
    @billing_month = billing_month
    @learning_partners = learning_partners
    @total_billed_days = 0
    @active_users_count = 0
    @is_recalculation_needed = is_recalculation_needed
  end

  def process
    process_learning_partners
  end

  private

  def process_learning_partners
    learning_partners.each do |learning_partner|
      billing_month_invoice = last_billing(learning_partner, billing_month.all_month)

      next if billing_month_invoice.present? && !is_recalculation_needed

      process_billing(learning_partner)
      destroy_existing_invoice!(billing_month_invoice) if is_recalculation_needed

      Invoice.create!(billable_days: @total_billed_days,
                      amount: @total_billed_days * Invoice::PER_DAY_RATE, active_users: @active_users_count,
                      bill_date: billing_month.end_of_month, learning_partner:)
      @total_billed_days = 0
      @active_users_count = 0
    end
  end

  def process_billing(learning_partner)
    last_billing_month_invoice = last_billing(learning_partner, billing_month.last_month.all_month)
    @active_users_count = last_billing_month_invoice&.active_users.to_i
    events = learning_partner_events(learning_partner, billing_month)

    if events.any?
      user_events = events.group_by { |e| e.data["target_user_id"] }
      deactivated_users_count = user_events.count { |_, user_event| user_event.first.name == "user_deactivated" }

      @total_billed_days = (@active_users_count - deactivated_users_count) * billing_month.end_of_month.day

      calculate_billable_days_from_events(events)
    else
      @total_billed_days+= @active_users_count*billing_month.end_of_month.day
    end
  end

  def learning_partner_events(learning_partner, billing_month)
    UserActivatedDeactivatedQuery.new(learning_partner.id, billing_month.all_month).call
  end

  def calculate_billable_days_from_events(events)
    billing_start_date = billing_month.beginning_of_month.to_date
    billing_end_date = billing_month.end_of_month.to_date

    active_periods = {}
    last_event_type = {}

    events.each do |event|
      user_id = event.data["target_user_id"]
      event_date = event.created_at.to_date

      next if last_event_type[user_id] == event.name

      if event.name == "user_activated"
        active_periods[user_id] = event_date
        @active_users_count += 1
      elsif event.name == "user_deactivated"
        activation_date = active_periods[user_id] || billing_start_date
        @total_billed_days += (event_date - activation_date).to_i
        active_periods.delete(user_id)
        @active_users_count -= 1
      end

      last_event_type[user_id] = event.name
    end

    active_periods.each_value do |activation_date|
      @total_billed_days += (billing_end_date - activation_date).to_i + 1
    end
  end

  def last_billing(learning_partner, bill_date)
    Invoice.where(learning_partner:)
                  .where(bill_date:)
                  .order(:bill_date)
                  .last
  end

  def destroy_existing_invoice!(last_month_invoice)
    last_month_invoice.destroy! if last_month_invoice
  end
end
