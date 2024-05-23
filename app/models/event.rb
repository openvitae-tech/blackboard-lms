class Event < ApplicationRecord

  include EventDefinitions

  VALID_EVENTS = %w(
    onboarding_initiated
    onboarding_completed
    user_invited
    user_joined
    user_login
    user_logout
    course_assigned
    course_started
    course_completed
    manager_changed
    mobile_number_changed
  )

  validates :name, presence: true
  validates :name, inclusion: { in: VALID_EVENTS , message: "%{value} is not a valid event name." }

end
