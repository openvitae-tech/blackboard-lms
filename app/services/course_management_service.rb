# frozen_string_literal: true

class CourseManagementService
  include Singleton
  include Errors
  include Rails.application.routes.url_helpers

  def enroll!(user, course, assigned_by = nil, deadline = nil)
    # Enrolling to an unpublished course is unacceptable
    unless course.published?
      raise InvalidEnrollmentError, "Cannot enroll to unpublished course. Course Id: #{course.id}"
    end

    return :duplicate if user.enrolled_for_course?(course)

    self_enrolled = assigned_by.nil?

    EVENT_LOGGER.publish_course_enrolled(user, course.id, self_enrolled)

    course.enroll!(user, assigned_by, deadline)

    NotificationService.notify(
      user,
      I18n.t('notifications.course.enrolled.title'),
      format(I18n.t('notifications.course.enrolled.message'), title: course.title), link: course_path(course)
    )
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
    EVENT_LOGGER.publish_time_spent(user, enrollment.course_id, time_spent_in_seconds)
    # do nothing if the lesson is already complete, only the first time complete will be
    # considered
    return if enrollment.lesson_completed?(lesson.id)

    enrollment.complete_lesson!(course_module.id, lesson.id, time_spent_in_seconds)
    NotificationService.notify(
      user,
      I18n.t('notifications.lesson.completed.title'),
      format(I18n.t('notifications.lesson.completed.message'), title: lesson.title),
      link: course_module_lesson_path(course_module.course, course_module, lesson)
    )

    if module_completed?(enrollment, course_module)
      enrollment.complete_module!(course_module.id)
      NotificationService.notify(
        user, I18n.t('notifications.course_module.completed.title'),
        format(I18n.t('notifications.course_module.completed.message'), title: course_module.title),
        link: course_module_path(course_module.course, course_module)
      )
    end

    return unless course_completed?(enrollment)

    enrollment.complete_course!
    EVENT_LOGGER.publish_course_completed(user, enrollment.course_id)
    UserMailer.course_completed(user, course_module.course).deliver_later
    NotificationService.notify(
      user,
      I18n.t('notifications.course.completed.title'),
      format(I18n.t('notifications.course.completed.message'), title: course_module.course.title),
      link: course_path(course_module.course)
    )
  end

  def set_lesson_attributes(_course_module, lesson)
    lesson.video_streaming_source = 'vimeo'
  end

  def assign_user_to_courses(user, courses_with_deadline, assigned_by)
    return unless user.is_learner?

    courses_with_deadline.each do |course, deadline|
      result = enroll!(user, course, assigned_by, deadline)
      next if result != :ok

      EVENT_LOGGER.publish_course_assigned(assigned_by, user.id, course.id)
      NotificationService.notify(user, I18n.t('course.assigned.title'),
                                 format(I18n.t('course.assigned.text'),
                                        course: course.title, name: assigned_by.name), link: course_path(course))
      UserMailer.course_assignment(user, assigned_by, course).deliver_later
    end
  end

  def assign_team_to_courses(team, courses_with_deadline, assigned_by)
    ActiveRecord::Base.transaction do
      # create team_enrollment record at team level
      courses_with_deadline.each do |(course, _)|
        next if team.enrolled_for_course?(course)

        course.enroll_team!(team, assigned_by)
      end
      # assigning to team assigns the course to each users in the team
      # therefore create enrollment record for each users in the team
      team.members.each do |user|
        assign_user_to_courses(user, courses_with_deadline, assigned_by)
      end
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

    quiz_answer =
      if enrollment.quiz_answered?(quiz)
        quiz_answer = enrollment.get_answer(quiz)
        quiz_answer.answer = answer
        quiz_answer.status = status
        quiz_answer
      else
        enrollment.quiz_answers.new(quiz:, status:, answer:, course_module_id: quiz.course_module_id)
      end

    quiz_answer.save!
    enrollment.set_score!(enrollment.score + quiz_answer.score)
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

  def redo_quiz(course_module, enrollment)
    score = enrollment.score_earned_for(course_module)
    enrollment.delete_recorded_answers_for(course_module)
    enrollment.set_score!(enrollment.score - score)
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
      move_up(ordering, record)
    when :down
      move_down(ordering, record)
    end

    parent.save! if parent.changed?
  end

  def move_up(ordering, record)
    index = ordering.find_index(record.id)

    ordering[index], ordering[index - 1] = ordering[index - 1], ordering[index] if index.positive?
  end

  def move_down(ordering, record)
    index = ordering.find_index(record.id)

    ordering[index], ordering[index + 1] = ordering[index + 1], ordering[index] if ordering[index + 1].present?
  end
end
