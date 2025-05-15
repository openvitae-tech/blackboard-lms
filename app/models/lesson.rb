# frozen_string_literal: true

class Lesson < ApplicationRecord
  belongs_to :course_module, counter_cache: true

  validates :title, presence: true
  validates :duration, presence: { message: I18n.t('lesson.duration_not_set') }
  validate :unique_local_content_lang
  validate :local_contents_present?

  has_many :local_contents, dependent: :destroy

  accepts_nested_attributes_for :local_contents, allow_destroy: true

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
end
