class MonthlyInvoiceCalculatorService
  attr_reader :billing_month

  def initialize(billing_month)
    @billing_month = billing_month
    @total_billed_days = 0
    @active_users_count = 0
  end

  def process
    process_learning_partners
  end

  private

  def process_learning_partners
    LearningPartner.find_each(batch_size: 10) do |learning_partner|
      process_billing(learning_partner)
      Invoice.create!(billable_days: @total_billed_days,
                      amount: @total_billed_days * Invoice::PER_DAY_RATE, active_users: @active_users_count,
                      bill_date: billing_month.end_of_month, learning_partner:)
      # puts "#{learning_partner.name}: #{@total_billed_days}, active users: #{@active_users_count}"
      @total_billed_days = 0
      @active_users_count = 0
    end
  end

  def process_billing(learning_partner)
    billing_start_date = billing_month.beginning_of_month.to_date
    billing_end_date = billing_month.end_of_month.to_date

    last_billing = Invoice.where(learning_partner: learning_partner)
                  .where(bill_date: billing_month.last_month.all_month)
                  .order(:bill_date)
                  .last
    @active_users_count = last_billing&.active_users.to_i
    events = fetch_learning_partner_events(learning_partner, billing_start_date, billing_end_date)

    if events.any?
      user_events = events.group_by { |e| e.data["target_user_id"] }
      deactivated_users_count = user_events.count { |_, user_event| user_event.first.name == "user_deactivated" }

      @total_billed_days = (@active_users_count - deactivated_users_count) * billing_month.end_of_month.day

      calculate_billable_days_from_events(events, billing_start_date, billing_end_date) #calculate bill for the existing learning partners
    else
      @total_billed_days+= @active_users_count*billing_month.end_of_month.day
    end
  end

  def fetch_learning_partner_events(learning_partner, billing_start_date, billing_end_date)
    Event.where(
      "partner_id = ? AND created_at BETWEEN ? AND ? AND name IN (?)",
      learning_partner.id, billing_start_date, billing_end_date, ["user_activated", "user_deactivated"]
    ).order(:created_at)
  end

  def calculate_billable_days_from_events(events, billing_start_date, billing_end_date)
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
end
