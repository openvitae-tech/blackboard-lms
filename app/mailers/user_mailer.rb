# frozen_string_literal: true

class UserMailer < ApplicationMailer
  include CommonsHelper

  layout 'mailer'

  def course_assignment(user, assigned_by, course)
    @user = user
    @assigned_by = assigned_by
    @course = course

    return if @user.email.blank? || email_disabled_for?(@user)

    mail(
      to: @user.email,
      subject: t('course.course_assigned')
    )
  end

  def course_deadline_reminder(user, course, deadline)
    @user = user
    @course = course
    @deadline = deadline.to_fs(:short)

    return if @user.email.blank? || email_disabled_for?(@user)

    mail(
      to: @user.email,
      subject: t('course.deadline_approaching')
    )
  end

  def course_completed(user, course)
    @user = user
    @course = course

    return if @user.email.blank? || email_disabled_for?(@user)

    mail(
      to: @user.email,
      subject: t('course.course_completed')
    )
  end
end
