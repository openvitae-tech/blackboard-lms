# frozen_string_literal: true

class EventService
  include Singleton
  # Events are simply published into database.
  def publish_event(user, event_data)
    event = build_event(user, event_data)
    publish_event_to_database(event) if event.valid?
  end

  def publish_onboarding_initiated(user, partner)
    event = Event::OnboardingInitiated.new(
      partner_name: partner.name,
      partner_id: partner.id
    )

    publish_event(user, event)
  end

  private

  def build_event(user, event_data)
    to_event_name = ->(obj) { obj.class.name.split('::')[1].underscore }
    Event.new do |e|
      e.name = to_event_name.call(event_data)
      e.partner_id = user.learning_partner_id
      e.user_id = user.id
      e.data = event_data.to_h
    end
  end

  def publish_event_to_database(event)
    event.save

    return if event.persisted?

    Rails.logger.error("Event logging failure: #{event.name}")
  end
end
