# frozen_string_literal: true

module CourseModulesHelper
  def module_delete_tooltip_message(course)
    if course.published?
      t('course.course_module.cannot_delete_published')
    else
      t('course.course_module.cannot_delete_enrolled')
    end
  end
end
