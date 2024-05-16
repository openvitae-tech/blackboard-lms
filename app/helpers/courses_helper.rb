module CoursesHelper
  def course_banner(course)
    return course.banner if course && course.banner.present?

    "course.jpeg"
  end

  def course_banner_thumbnail(course)
    return course.banner if course && course.banner.variant(resize_to_limit: [nil, 200])

    "course_thumbnail.jpeg"
  end

  def next_lesson_path(course, course_module, current_lesson)
    next_lesson = course_module.next_lesson(current_lesson)

    if next_lesson.present?
      course_module_lesson_path(course, course_module, next_lesson)
    else
      "javascript:void(0)"
    end
  end

  def prev_lesson_path(course, course_module, current_lesson)
    prev_lesson = course_module.prev_lesson(current_lesson)

    if prev_lesson.present?
      course_module_lesson_path(course, course_module, prev_lesson)
    else
      "javascript:void(0)"
    end
  end

end
