# frozen_string_literal: true

class Lesson < ApplicationRecord
  belongs_to :course_module, counter_cache: true
  has_many :local_contents, dependent: :destroy

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

  def video_url_for_lang(lang)
    if lang.blank? || lang == LocalContent::DEFAULT_LANGUAGE
      video_url
    else
      local_contents.where(lang: lang).first&.video_url || ''
    end
  end
end
