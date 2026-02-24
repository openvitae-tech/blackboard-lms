# frozen_string_literal: true

class Course < ApplicationRecord
  include CustomValidations
  include CourseJson

  ENROLLED_COURSES_LIMIT = 4
  PER_PAGE_LIMIT = 12

  enum :visibility, { public: 'public', private: 'private' }, prefix: :visibility

  has_many :course_modules, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :assessments, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments
  has_and_belongs_to_many :tags # rubocop:disable Rails/HasAndBelongsToMany

  has_many :team_enrollments, dependent: :destroy
  has_many :teams, through: :team_enrollments
  has_many :program_courses, dependent: :destroy
  has_many :programs, through: :program_courses

  has_one_attached :banner
  has_many_attached :materials

  validates :title, presence: true, length: { minimum: 6, maximum: 255 }
  validates :description, presence: true, length: { minimum: 32, maximum: 1024 }
  validates :visibility, presence: true

  validate :acceptable_materials
  validate :acceptable_banner
  validate :unique_tags

  scope :published, -> { where(is_published: true) }

  def enroll!(user, assigned_by = nil, deadline = nil)
    enrollments.create!(user:, assigned_by:, deadline_at: deadline)
  end

  def enroll_team!(team, assigned_by)
    team_enrollments.create!(team:, assigned_by:)
  end

  def undo_enroll!(user)
    # there will be only one enrollment record for a user, course pair
    enrollments.where(user:).find_each(&:destroy)
  end

  def lessons_count
    course_modules.map(&:lessons_count).reduce(:+) || 0
  end

  def quizzes_count
    course_modules.map(&:quizzes_count).reduce(:+) || 0
  end

  def first_module
    first_module_id = course_modules_in_order.first
    course_modules.find(first_module_id) if first_module_id.present?
  end

  def last_module
    last_module_id = course_modules_in_order.last
    course_modules.find(last_module_id) if last_module_id.present?
  end

  def next_module(current_module)
    index = course_modules_in_order.find_index(current_module.id)
    course_modules.find(course_modules_in_order[index + 1]) if course_modules_in_order[index + 1].present?
  end

  def prev_module(current_module)
    index = course_modules_in_order.find_index(current_module.id)
    course_modules.find(course_modules_in_order[index - 1]) if index.positive?
  end

  def published?
    is_published
  end

  def publish!
    update(is_published: true)
  end

  def undo_publish!
    update(is_published: false)
  end

  def enrollments_present?
    enrollments_count.positive?
  end

  def ready_to_publish?
    rule_at_least_one_module = course_modules_count.positive?
    rule_at_least_one_lesson_per_module = course_modules.map do |course_module|
      course_module.lessons_count.positive?
    end.all?
    [rule_at_least_one_module, rule_at_least_one_lesson_per_module].all?
  end

  def recalculate_course_duration!
    self.duration = course_modules.includes(:lessons).map(&:duration).reduce(&:+) || 0
    save!
  end

  def modules_in_order
    @modules_in_order ||= RecordOrdering.records_in_order(course_modules, course_modules_in_order)
  end

  private

  def unique_tags
    duplicates = tags.group_by(&:id).select { |_, group| group.size > 1 }
    return unless duplicates.any?

    errors.add(:course, 'cannot have duplicate tags')
  end
end
