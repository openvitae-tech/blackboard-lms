# frozen_string_literal: true

class Event < ApplicationRecord
  VALID_EVENTS = %w[
    onboarding_initiated
    first_user_joined
    user_invited
    user_joined
    user_login
    user_logout
    course_assigned
    course_enrolled
    course_started
    course_completed
    learning_time_spent
    course_viewed
    lesson_viewed
  ].freeze

  OnboardingInitiated = Struct.new(:partner_id, :partner_name,  keyword_init: true)
  FirstUserJoined = Struct.new(:partner_id, :team_id, :user_id, :partner_name, :email, keyword_init: true)
  UserInvited = Struct.new(:partner_id, :team_id, :user_id, :invite_email, keyword_init: true) # user invited by owner or manager not by admin
  UserJoined = Struct.new(:partner_id, :team_id, :user_id, :invite_email, keyword_init: true) # user joined via an invite
  UserLogin = Struct.new(:partner_id, :team_id, :user_id, :login_type, keyword_init: true)
  UserLogout = Struct.new(:partner_id, :team_id, :user_id, keyword_init: true)
  CourseAssigned = Struct.new(:partner_id, :team_id, :user_id, :assigned_to_user, :course_id, keyword_init: true)
  CourseEnrolled = Struct.new(:partner_id, :team_id, :user_id, :course_id, :self_enroll, keyword_init: true)
  CourseDropped = Struct.new(:partner_id, :team_id, :user_id, :course_id, keyword_init: true)
  CourseStarted = Struct.new(:partner_id, :team_id, :user_id, :course_id, keyword_init: true)
  CourseCompleted = Struct.new(:partner_id, :team_id, :user_id, :course_id, keyword_init: true)
  LearningTimeSpent = Struct.new(:partner_id, :team_id, :user_id, :course_id, :time_spent, keyword_init: true)
  CourseViewed = Struct.new(:partner_id, :team_id, :user_id, :course_id, keyword_init: true)
  LessonViewed = Struct.new(:partner_id, :team_id, :user_id, :course_id, :lesson_id, keyword_init: true)

  validates :name, presence: true
  validates :name, inclusion: { in: VALID_EVENTS, message: '%<value>s is not a valid event name.' }
end
