# frozen_string_literal: true

class EventService
  include Singleton
  # Events are simply published into database.
  def publish_event(user, event_data)
    # A UUID might be need to avoid event duplication when moving to
    # a queue based system
    event = build_event(user, event_data)

    begin
      publish_event_to_database(event) if event.valid?
    rescue StandardError => e
      Rails.logger.error "Error: publishing events #{e.message}"
    end
  end

  def publish_onboarding_initiated(user, partner)
    event = Event::OnboardingInitiated.new(
      partner_name: partner.name,
      partner_id: partner.id
    )

    publish_event(user, event)
  end

  def publish_first_user_joined(user, partner)
    event = Event::FirstUserJoined.new(
      partner_id: partner.id,
      email: user.email,
      team_id: user.team_id,
      user_id: user.id,
      partner_name: partner.name
    )

    publish_event(user, event)
  end

  def publish_user_invited(user, invitee)
    event = Event::UserInvited.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: invitee.team_id,
      invite_email: invitee.email
    )

    publish_event(user, event)
  end

  def publish_user_joined(user)
    event = Event::UserJoined.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      invite_email: user.email
    )

    publish_event(user, event)
  end

  def publish_user_login(user)
    event = Event::UserLogin.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
    )

    publish_event(user, event)
  end

  def publish_user_logout(user)
    event = Event::UserLogout.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id
    )

    publish_event(user, event)
  end

  def publish_course_assigned(user, other_user_id, course_id)
    event = Event::CourseAssigned.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      assigned_to_user: other_user_id,
      course_id: course_id
    )

    publish_event(user, event)
  end

  def publish_course_enrolled(user, course_id, self_enroll)
    event = Event::CourseEnrolled.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      course_id: course_id,
      self_enroll: self_enroll
    )

    publish_event(user, event)
  end

  def publish_course_dropped(user, course_id)
    event = Event::CourseDropped.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      course_id: course_id,
    )

    publish_event(user, event)
  end

  def publish_course_started(user, course_id)
    event = Event::CourseStarted.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      course_id: course_id
      )

    publish_event(user, event)
  end

  def publish_course_completed(user, course_id)
    event = Event::CourseCompleted.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      course_id: course_id
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

    Rails.logger.error "Error: publishing events #{event.name}, failed due to invalid modal object"
  end
end
