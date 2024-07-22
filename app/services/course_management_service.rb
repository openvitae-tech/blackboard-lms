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

  def complete!(user, course, course_module, lesson, time_spent_in_seconds)
    enrollment = user.enrollments.where(course: course).first
    enrollment.set_progress!(course_module.id, lesson.id, time_spent_in_seconds)
  end

  def search(term)
    Course.where("title ilike ?", "%#{term}%")
  end

  def set_lesson_attributes(course_module, lesson)
    lesson.video_streaming_source = "vimeo"
  end

  def assign_user_to_courses(user, courses, assigned_by)
    courses.each do |course|
      unless user.enrolled_for_course?(course)
        course.enroll!(user, assigned_by)
        Notification.notify(user, I18n.t("course.assigned") % { course: course.title, name: assigned_by.name })
      end
    end
  end

  def record_answer!(enrollment, quiz, answer)
    answer.downcase!
    status = if answer == "skip"
               QuizAnswer::STATUS_MAPPING[:skipped]
             elsif answer == quiz.answer.downcase
               QuizAnswer::STATUS_MAPPING[:correct]
             else
               QuizAnswer::STATUS_MAPPING[:incorrect]
             end
    enrollment.quiz_answers.create!(quiz: quiz, status: status, answer: answer)
  end

  def update_lesson_ordering!(course_module, lesson, action)
    update_ordering!(course_module, lesson, action)
  end

  def update_quiz_ordering!(course_module, quiz, action)
    update_ordering!(course_module, quiz, action)
  end

  def update_module_ordering(course, course_module, action)
    update_ordering!(course, course_module, action)
  end

  def publish!(course)
    return :duplicate if course.published?
    course.publish!
    :ok
  end

  def undo_publish!(course)
    return :duplicate unless course.published?
    course.undo_publish!
    :ok
  end

  private
  def update_ordering!(parent, record, action)
    ordering_method = "#{record.class.to_s.underscore.pluralize}_in_order".to_sym
    ordering = parent.send(ordering_method)

    if action == :destroy
      ordering.delete(record.id)
    elsif action == :create
      ordering.append(record.id) unless ordering.include? record.id
    elsif action == :up
      i = ordering.find_index(record.id)

      if i > 0
        ordering[i], ordering[i-1] = ordering[i-1], ordering[i]
      end
    elsif action == :down
      i = ordering.find_index(record.id)

      if ordering[i+1].present?
        ordering[i], ordering[i+1] = ordering[i+1], ordering[i]
      end
    end

    parent.save! if parent.changed?
  end
end