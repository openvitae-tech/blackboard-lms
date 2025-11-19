# frozen_string_literal: true

class Lesson < ApplicationRecord
  belongs_to :course_module, counter_cache: true

  validates :title, presence: true
  validates :duration, presence: { message: I18n.t('lesson.duration_not_set') }
  validate :unique_local_content_lang
  validate :local_contents_present?

  has_many :local_contents, dependent: :destroy

  has_rich_text :rich_description

  accepts_nested_attributes_for :local_contents, allow_destroy: true

  # whenever there is a change in duration attribute of the lesson
  # we set the virtual flag `recompute_course_duration_flag` to true.
  # After saving the lesson the duration of the course is recomputed and
  # cached in the course model to avoid recomputing the same while listing the
  # course
  attr_accessor :recompute_course_duration_flag

  before_save :set_recompute_course_duration_flag
  after_save :update_course_duration

  def current_rating
    service = Lessons::RatingService.instance
    service.diminished_rating(rating, last_rated_at)
  end

  def transcripts
    local_contents.in_english.first&.transcripts
  end

  def transcript_text
    transcripts.present? ? transcripts.pluck(:text).join(' ') : ''
  end

  private

  def unique_local_content_lang
    langs = local_contents.reject(&:marked_for_destruction?).map(&:lang)
    duplicate_langs = langs.select { |lang| langs.count(lang) > 1 }.uniq

    errors.add(:base, I18n.t('lesson.duplicate_lesson', langs: duplicate_langs.join(', '))) if duplicate_langs.any?
  end

  def local_contents_present?
    return false unless local_contents.reject(&:marked_for_destruction?).empty?

    errors.add(:base,
               I18n.t('lesson.must_have_local_content'))
  end

  def update_course_duration
    return unless recompute_course_duration_flag

    course_module.course.recalculate_course_duration!
    self.recompute_course_duration_flag = false
  end

  def set_recompute_course_duration_flag
    self.recompute_course_duration_flag = duration_changed?
  end
end
