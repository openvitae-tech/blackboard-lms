# frozen_string_literal: true

class CourseDeadlineReminderJob < BaseJob
  def perform
    enrollments = Enrollment.where(deadline_at: Time.zone.now..3.days.from_now)

    enrollments.each do |enrollment|
      # send at most one email per day, kept 1 hours as buffer for any retries
      if enrollment.reminder_send_at.blank? || enrollment.reminder_send_at < 23.hours.ago
        UserMailer.course_deadline_reminder(enrollment.user, enrollment.course, enrollment.deadline_at).deliver_later
        enrollment.touch(:reminder_send_at)
      end
    end
  end
end