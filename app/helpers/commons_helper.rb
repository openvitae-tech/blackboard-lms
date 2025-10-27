# frozen_string_literal: true

module CommonsHelper
  def payment_plan_days_remaining(start_date, end_date)
    start_date = start_date.to_date
    end_date = end_date.to_date

    (end_date - start_date).to_i
  end

  def activate_users_count(learning_partner)
    learning_partner.payment_plan.total_seats - learning_partner.active_users_count
  end

  def log_error_to_sentry(msg, response = nil)
    extra = response ? { status: response.code, body: response.body } : {}
    Sentry.capture_message(msg, level: :error, extra: extra)
  end

  def validate_llm_model(model, supported_models)
    return unless model && supported_models.exclude?(model)

    raise ArgumentError,
          "Unsupported model '#{model}'. Allowed: #{supported_models.join(', ')}"
  end

  def email_disabled_for?(user)
    user.email.blank? || user.is_support?
  end
end
