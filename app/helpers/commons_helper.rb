# frozen_string_literal: true

module CommonsHelper
  def payment_plan_days_remaining(start_date, end_date)
    start_date = start_date.to_date
    end_date = end_date.to_date

    (end_date - start_date).to_i
  end

  def activate_users_count(learning_partner)
    support_user = learning_partner.users.find_by(role: 'support')
    active_count = learning_partner.active_users_count

    active_count -= 1 if support_user.present?
    learning_partner.payment_plan.total_seats - active_count
  end
end
