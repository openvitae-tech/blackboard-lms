# frozen_string_literal: true

module QuizzesHelper
  def quiz_delete_tooltip_message(course)
    if course.published?
      t('quiz.cannot_delete_published')
    else
      t('quiz.cannot_delete_enrolled')
    end
  end
end
