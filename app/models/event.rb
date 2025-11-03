# frozen_string_literal: true

class Event < ApplicationRecord
  ONBOARDING_INITIATED = 'onboarding_initiated'
  FIRST_USER_JOINED = 'first_user_joined'
  USER_INVITED = 'user_invited'
  USER_JOINED = 'user_joined'
  USER_LOGIN = 'user_login'
  USER_LOGOUT = 'user_logout'
  COURSE_ASSIGNED = 'course_assigned'
  COURSE_ENROLLED = 'course_enrolled'
  COURSE_STARTED = 'course_started'
  COURSE_COMPLETED = 'course_completed'
  LEARNING_TIME_SPENT = 'learning_time_spent'
  COURSE_VIEWED = 'course_viewed'
  LESSON_VIEWED = 'lesson_viewed'
  USER_ACTIVATED = 'user_activated'
  USER_DEACTIVATED = 'user_deactivated'
  ACTIVE_USER_COUNT = 'active_user_count'
  PAYMENT_PLAN_MODIFIED = 'payment_plan_modified'
  EMAIL_VERIFIED = 'email_verified'
  LESSON_RATING = 'lesson_rating'

  VALID_EVENTS = [
    ONBOARDING_INITIATED,
    FIRST_USER_JOINED,
    USER_INVITED,
    USER_JOINED,
    USER_LOGIN,
    USER_LOGOUT,
    COURSE_ASSIGNED,
    COURSE_ENROLLED,
    COURSE_STARTED,
    COURSE_COMPLETED,
    LEARNING_TIME_SPENT,
    COURSE_VIEWED,
    LESSON_VIEWED,
    USER_ACTIVATED,
    USER_DEACTIVATED,
    ACTIVE_USER_COUNT,
    PAYMENT_PLAN_MODIFIED,
    EMAIL_VERIFIED,
    LESSON_RATING
  ].freeze

  OnboardingInitiated = Struct.new(:partner_id, :partner_name, keyword_init: true)
  FirstUserJoined = Struct.new(:partner_id, :team_id, :user_id, :partner_name, :phone, keyword_init: true)
  # user invited by owner or manager not by admin
  UserInvited = Struct.new(:partner_id, :team_id, :user_id, :invite_phone, keyword_init: true)
  # user joined via an invite
  UserJoined = Struct.new(:partner_id, :team_id, :user_id, :phone, keyword_init: true)
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
  UserActivated = Struct.new(:partner_id, :team_id, :user_id, :target_user_id, keyword_init: true)
  UserDeactivated = Struct.new(:partner_id, :team_id, :user_id, :target_user_id, keyword_init: true)
  ActiveUserCount = Struct.new(:partner_id, :team_id, :user_id, :active_user_count, keyword_init: true)
  PaymentPlanModified = Struct.new(:partner_id, :user_id, :payment_plan_id, :plan_start_date, :plan_end_date,
                                   :per_seat_amount, :total_seats, keyword_init: true)
  EmailVerified = Struct.new(:partner_id, :team_id, :user_id, :email, keyword_init: true)
  LessonRating = Struct.new(:user_id, :lesson_id, :team_id, :partner_id, :rating, keyword_init: true)

  validates :name, presence: true
  validates :name, inclusion: { in: VALID_EVENTS, message: I18n.t('event.invalid') }
end
