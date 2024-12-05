# frozen_string_literal: true

class CourseManagementService
  include Singleton
  def enroll!(user, course)
    return :duplicate if user.enrolled_for_course?(course)

    EVENT_LOGGER.publish_course_enrolled(user, course.id)

    course.enroll!(user)
    :ok
  end

  def undo_enroll!(user, course)
    return :not_enrolled unless user.enrolled_for_course?(course)

    course.undo_enroll!(user)
    EVENT_LOGGER.publish_course_dropped(user, course.id)
    :ok
  end

  def proceed(user, course)
    return :not_enrolled unless user.enrolled_for_course?(course)

    user.enrollments.where(course:).first
  end

  # should be used only during completing a lesson otherwise use enrollment.module_completed?
  def module_completed?(enrollment, course_module)
    lesson_ids = course_module.lessons.map(&:id)
    return false if lesson_ids.empty?

    diff = lesson_ids - enrollment.completed_lessons
    diff.empty?
  end

  # should be used only during completing a lesson otherwise user enrollment.course_completed?
  def course_completed?(enrollment)
    module_ids = enrollment.course.course_modules.map(&:id)
    return false if module_ids.empty?

    diff = module_ids - enrollment.completed_modules
    diff.empty?
  end

  def set_progress!(user, enrollment, course_module, lesson, time_spent_in_seconds)
    EVENT_LOGGER.publish_time_spent(user, time_spent_in_seconds)
    # do nothing if the lesson is already complete, only the first time complete will be
    # considered
    return if enrollment.lesson_completed?(lesson.id)

    enrollment.complete_lesson!(course_module.id, lesson.id, time_spent_in_seconds)

    enrollment.complete_module!(course_module.id) if module_completed?(enrollment, course_module)

    if course_completed?(enrollment)
      enrollment.complete_course!
      EVENT_LOGGER.publish_course_completed(user, enrollment.course_id)
    end
  end

  def search(user, term)
    if user.is_admin?
      Course.where('title ilike ?', "%#{term}%")
    else
      Course.published.where('title ilike ?', "%#{term}%")
    end
  end

  def set_lesson_attributes(_course_module, lesson)
    lesson.video_streaming_source = 'vimeo'
  end

  def assign_user_to_courses(user, courses_with_deadline, assigned_by)
    courses_with_deadline.each do |course, deadline|
      next if user.enrolled_for_course?(course)

      course.enroll!(user, assigned_by, deadline)
      EVENT_LOGGER.publish_course_assigned(assigned_by, user.id, course.id)
      Notification.notify(user, format(I18n.t('course.assigned'), course: course.title, name: assigned_by.name))
      UserMailer.course_assignment(user, assigned_by, course).deliver_later
    end
  end

  def assign_team_to_courses(team, courses_with_deadline, assigned_by)
    team.members.each do |user|
      assign_user_to_courses(user, courses_with_deadline, assigned_by)
    end
  end

  def record_answer!(enrollment, quiz, answer)
    answer.downcase!
    status = if answer == 'skip'
               QuizAnswer::STATUS_MAPPING[:skipped]
             elsif answer == quiz.answer.downcase
               QuizAnswer::STATUS_MAPPING[:correct]
             else
               QuizAnswer::STATUS_MAPPING[:incorrect]
             end

    quiz_answer = enrollment.quiz_answers.new(quiz:, status:, answer:, course_module_id: quiz.course_module_id)
    quiz_answer.save!
    enrollment.update_score!(quiz_answer.score)
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

  def replay!(enrollment, lesson)
    return false unless enrollment.lesson_completed?(lesson.id)

    enrollment.mark_as_incomplete!(lesson)
  end

  def redo_quiz(course_module, enrollment)
    score = enrollment.score_earned_for(course_module)
    enrollment.delete_recorded_answers_for(course_module)
    enrollment.update_score!(score)
  end

  private

  def update_ordering!(parent, record, action)
    ordering_method = :"#{record.class.to_s.underscore.pluralize}_in_order"
    ordering = parent.send(ordering_method)

    case action
    when :destroy
      ordering.delete(record.id)
    when :create
      ordering.append(record.id) unless ordering.include? record.id
    when :up
      i = ordering.find_index(record.id)

      ordering[i], ordering[i - 1] = ordering[i - 1], ordering[i] if i.positive?
    when :down
      i = ordering.find_index(record.id)

      ordering[i], ordering[i + 1] = ordering[i + 1], ordering[i] if ordering[i + 1].present?
    end

    parent.save! if parent.changed?
  end
end
