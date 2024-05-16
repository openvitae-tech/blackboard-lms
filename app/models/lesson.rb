class Lesson < ApplicationRecord
  belongs_to :course_module, counter_cache: true
end
