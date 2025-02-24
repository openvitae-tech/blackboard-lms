class MonthlyBillingCalculator
  def initialize
    @total_billed_days = 0
  end

  def process
    process_learning_partners
    @total_billed_days
  end

  private

  def process_learning_partners
    LearningPartner.find_each(batch_size: 10) do |learning_partner|
      process_users_billing(learning_partner.users)
    end
  end

  def process_users_billing(users)
    billing_month = Time.zone.now.last_month
    billing_start_date = billing_month.beginning_of_month.to_date
    billing_end_date = billing_month.end_of_month.to_date

    users.find_each do |user|
      events = fetch_user_events(user, billing_start_date, billing_end_date)
      if events.any?
        calculate_billable_days_from_events(events, billing_start_date, billing_end_date)
      elsif user.state == "active" || last_user_event.name == "user_activated"
        @total_billed_days += (billing_end_date - billing_start_date + 1).to_i
      end
    end
  end

  def fetch_user_events(user, billing_start_date, billing_end_date)
    Event.where(
      "data->>'target_user_id' = ? AND created_at BETWEEN ? AND ? AND name IN (?)",
      user.id, billing_start_date, billing_end_date, ["user_activated", "user_deactivated"]
    ).order(:created_at)
  end

  def calculate_billable_days_from_events(events, billing_start_date, billing_end_date)
    last_activation_date = nil
    last_event_type = nil


    events.each do |event|
      next if event.name == last_event_type

      if event.name == "user_activated"
        last_activation_date = event.created_at.to_date
      elsif event.name == "user_deactivated"
        activation_date = last_activation_date || billing_start_date
        @total_billed_days += (event.created_at.to_date - activation_date + 1).to_i
        last_activation_date = nil
      end
      last_event_type = event.name
    end

    @total_billed_days += (billing_end_date - last_activation_date + 1).to_i if last_activation_date
  end

  def last_user_event(user, billing_start_date, billing_end_date)
    Event.where(
      "data->>'target_user_id' = ? AND created_at < ? AND name IN (?)",
      user.id, billing_start_date, ["user_activated", "user_deactivated"]
    ).order(:created_at).last
  end
end
