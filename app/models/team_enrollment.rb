# frozen_string_literal: true
#
# modal for tracking the enrollments at a team level
# all the fine details of the enrolments will be still kept at the
# Enrollment table.
class TeamEnrollment < ApplicationRecord
  belongs_to :team, counter_cache: true
  belongs_to :course, counter_cache: true
  belongs_to :assigned_by, class_name: 'User', foreign_key: 'assigned_by_id'
end
