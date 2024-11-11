# frozen_string_literal: true

class Lesson < ApplicationRecord
  belongs_to :course_module, counter_cache: true

  validates :title, presence: true
  validate :unique_local_content_lang
  validate :has_local_contents?

  has_many :local_contents, dependent: :destroy

  validate :has_local_contents?

  has_rich_text :rich_description

  accepts_nested_attributes_for :local_contents, allow_destroy: true

  def progress
    @temp_progress ||= rand(0..100)

    if @temp_progress > 80
      100
    elsif @temp_progress > 50
      @temp_progress
    else
      0
    end
  end

  private

  def unique_local_content_lang
    langs = local_contents.reject(&:marked_for_destruction?).map(&:lang)
    duplicate_langs = langs.select { |lang| langs.count(lang) > 1 }.uniq

    errors.add(:base, I18n.t("lesson.duplicate_lesson", langs: duplicate_langs.join(', '))) if duplicate_langs.any?
  end

  def has_local_contents?
    errors.add(:base, I18n.t("lesson.must_have_local_content")) if local_contents.reject(&:marked_for_destruction?).empty?
  end
end
