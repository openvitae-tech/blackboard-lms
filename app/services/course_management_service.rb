class CourseManagementService
  include Singleton
  def enroll(user, course)
    return :duplicate if user.enrolled_for_course?(course)
    course.enroll(user)
    :ok
  end

  def undo_enroll(user, course)
    return :not_enrolled unless user.enrolled_for_course?(course)
    course.undo_enroll(user)
    :ok
  end

  def search(term)
    Course.where("title ilike ?", "%#{term}%")
  end

  def set_sequence_number_for_lesson(course_module, lesson)
    lesson.seq_no = course_module.lessons_count + 1
  end

  def set_sequence_number_for_module(course, course_module)
    course_module.seq_no = course.course_modules_count + 1
  end
end