class EventService
  include Singleton
  # Events are simply published into database.
  def publish_event(event_data)
    event = build_event(event_data)
    publish_event_to_database(event) if event.valid?
  end

  private
    def build_event(event_data)
      Event.new do |e|
        e.name = event_data[:name]
        e.partner_id = event_data[:partner_id] || event_data[:partner].id
        e.user_id = event_data[:user_id] || event_data[:user].id
      end
    end
    def publish_event_to_database(event)
      event.save

      unless event.persisted?
        Rails.logger.error("Event logging failure: #{event.name}")
      end
    end
end