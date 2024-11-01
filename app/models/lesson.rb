# frozen_string_literal: true

class Lesson < ApplicationRecord
  belongs_to :course_module, counter_cache: true

  validates :title, presence: true

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
end
