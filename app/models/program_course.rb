# frozen_string_literal: true

class ProgramCourse < ApplicationRecord
  belongs_to :program, counter_cache: :courses_count
  belongs_to :course

  validates :course_id, uniqueness: {
    scope: :program_id,
    message: ->(object, _data) { I18n.t('program_course.already_added', course_name: object.course.title) }
  }
end
