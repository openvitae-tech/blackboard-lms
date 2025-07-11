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
      phone: user.phone,
      team_id: user.team_id,
      user_id: user.id,
      partner_name: partner.name
    )

    publish_event(user, event)
  end

  def publish_user_invited(user, invitee)
    event = Event::UserInvited.new(
      partner_id: invitee.learning_partner_id,
      user_id: user.id,
      team_id: invitee.team_id,
      invite_phone: invitee.phone
    )

    publish_event(user, event)
  end

  def publish_user_joined(user)
    event = Event::UserJoined.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      phone: user.phone
    )

    publish_event(user, event)
  end

  def publish_user_login(user, login_type)
    event = Event::UserLogin.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      login_type:
    )

    publish_event(user, event)
  end

  def publish_user_logout(user_id, team_id, partner_id)
    event = Event::UserLogout.new(partner_id:, user_id:, team_id:)

    tmp_user = User.new(id: user_id, team_id:, learning_partner_id: partner_id)

    publish_event(tmp_user, event)
  end

  def publish_course_assigned(user, other_user_id, course_id)
    event = Event::CourseAssigned.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      assigned_to_user: other_user_id,
      course_id:
    )

    publish_event(user, event)
  end

  def publish_course_enrolled(user, course_id, self_enroll)
    event = Event::CourseEnrolled.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      course_id:,
      self_enroll:
    )

    publish_event(user, event)
  end

  def publish_course_dropped(user, course_id)
    event = Event::CourseDropped.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      course_id:
    )

    publish_event(user, event)
  end

  def publish_course_started(user, course_id)
    event = Event::CourseStarted.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      course_id:
    )

    publish_event(user, event)
  end

  def publish_course_completed(user, course_id)
    event = Event::CourseCompleted.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      course_id:
    )

    publish_event(user, event)
  end

  def publish_time_spent(user, course_id, time_spent_in_seconds)
    event = Event::LearningTimeSpent.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      course_id:,
      time_spent: time_spent_in_seconds
    )

    publish_event(user, event)
  end

  def publish_course_viewed(user, course_id)
    event = Event::CourseViewed.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      course_id:
    )

    publish_event(user, event)
  end

  def publish_lesson_viewed(user, course_id, lesson_id)
    event = Event::LessonViewed.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      course_id:,
      lesson_id:
    )

    publish_event(user, event)
  end

  def publish_user_activated(user, target_user)
    event = Event::UserActivated.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      target_user_id: target_user.id
    )

    publish_event(user, event)
  end

  def publish_user_deactivated(user, target_user)
    event = Event::UserDeactivated.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      target_user_id: target_user.id
    )

    publish_event(user, event)
  end

  def publish_active_user_count(user)
    active_user_count = user.learning_partner.users.where(state: 'active').count
    event = Event::ActiveUserCount.new(
      partner_id: user.learning_partner_id,
      user_id: user.id,
      team_id: user.team_id,
      active_user_count:
    )

    publish_event(user, event)
  end

  def publish_payment_plan_modified(user, learning_partner)
    event = Event::PaymentPlanModified.new(
      partner_id: learning_partner.id,
      user_id: user.id,
      payment_plan_id: learning_partner.payment_plan.id,
      plan_start_date: learning_partner.payment_plan.start_date,
      plan_end_date: learning_partner.payment_plan.end_date,
      per_seat_amount: learning_partner.payment_plan.per_seat_cost,
      total_seats: learning_partner.payment_plan.total_seats
    )

    publish_event(user, event)
  end

  def publish_email_verified(user)
    event = Event::EmailVerified.new(
      partner_id: user.learning_partner.id,
      user_id: user.id,
      team_id: user.team_id,
      email: user.email
    )

    publish_event(user, event)
  end

  private

  def build_event(user, event_data)
    to_event_name = ->(obj) { obj.class.name.split('::')[1].underscore }
    event_data_hash = event_data.to_h.with_indifferent_access

    Event.new do |e|
      e.name = to_event_name.call(event_data)
      e.partner_id = event_data_hash[:partner_id]
      e.user_id = user.id
      e.data = event_data_hash
    end
  end

  def publish_event_to_database(event)
    event.save

    return if event.persisted?

    Rails.logger.error "Error: publishing events #{event.name}, failed due to invalid modal object"
  end
end
