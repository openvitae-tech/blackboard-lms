class CourseManagementService
  include Singleton
  def enroll!(user, course)
    return :duplicate if user.enrolled_for_course?(course)
    course.enroll!(user)
    :ok
  end

  def undo_enroll!(user, course)
    return :not_enrolled unless user.enrolled_for_course?(course)
    course.undo_enroll!(user)
    :ok
  end

  def proceed(user, course)
    return :not_enrolled unless user.enrolled_for_course?(course)
    user.enrollments.where(course: course).first
  end

  def complete!(user, course, course_module, lesson)
    enrollment = user.enrollments.where(course: course).first
    enrollment.set_progress!(course_module.id, lesson.id)
  end

  def search(term)
    Course.where("title ilike ?", "%#{term}%")
  end

  def set_module_attributes(course, course_module)
    set_sequence_number_for_module(course, course_module)
  end

  def set_lesson_attributes(course_module, lesson)
    set_sequence_number_for_lesson(course_module, lesson)
    lesson.video_streaming_source = "vimeo"
  end

  def set_quiz_attributes(course_module, quiz)
    set_sequence_number_for_quiz(course_module, quiz)
  end
  def set_sequence_number_for_quiz(course_module, quiz)
    quiz.seq_no = course_module.lessons_count + 1
  end

  def set_sequence_number_for_lesson(course_module, lesson)
    lesson.seq_no = course_module.lessons_count + 1
  end

  def set_sequence_number_for_module(course, course_module)
    course_module.seq_no = course.course_modules_count + 1
  end

  def assign_user_to_courses(user, courses, assigned_by)
    courses.each do |course|
      unless user.enrolled_for_course?(course)
        course.enroll!(user, assigned_by)
        Notification.notify(user, I18n.t("course.assigned") % { course: course.title, name: assigned_by.name })
      end
    end
  end
end