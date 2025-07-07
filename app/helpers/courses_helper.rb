# frozen_string_literal: true

module CoursesHelper
  def enrolled_courses?(courses)
    defined?(courses) && courses.present?
  end

  def available_courses?(courses)
    defined?(courses) && courses.present?
  end

  # @param version [Symbol] Values are :vertical or :horizontal
  def course_banner(course, version)
    return STATIC_ASSETS[:course_banner] unless course.banner.attached?
    # HACK: for local testing with production dump data
    return STATIC_ASSETS[:course_banner] if Rails.env.local? && course.banner.blob.service_name.start_with?('s3')

    if version == :vertical
      course.banner&.variant(resize_to_fill: [320, nil])
    elsif version == :horizontal
      course.banner&.variant(resize_to_limit: [nil, 320])
    else
      course.banner
    end
  end

  def course_description(course, limit = nil)
    return '' if course.description.blank?

    text = limit.present? ? course.description[0..limit] : course.description
    sanitize text
  end

  def next_lesson_path(course, course_module, current_lesson)
    next_lesson = course_module.next_lesson(current_lesson)

    if next_lesson.blank?
      course_module = course_module.next_module
      next_lesson = course_module.first_lesson if course_module.present?
    end

    return if next_lesson.blank?

    course_module_lesson_path(course, course_module, next_lesson)
  end

  def prev_lesson_path(course, course_module, current_lesson)
    prev_lesson = course_module.prev_lesson(current_lesson)

    if prev_lesson.blank?
      course_module = course_module.prev_module
      prev_lesson = course_module.last_lesson if course_module.present?
    end

    return if prev_lesson.blank?

    course_module_lesson_path(course, course_module, prev_lesson)
  end

  def enroll_count(course)
    return course.enrollments_count if current_user.is_admin?

    number_with_delimiter(partner_metrics.course_enrollment_counts_for(course))
  end

  def modules_count(course)
    pluralize(course.course_modules_count, 'module')
  end

  def lessons_count(course_module)
    pluralize(course_module.lessons_count, 'lesson')
  end

  def course_duration(course)
    duration_in_words(course.duration)
  end

  def lesson_completed?(enrollment, lesson)
    enrollment.present? && enrollment.completed_lessons.include?(lesson.id)
  end

  def module_completed?(enrollment, course_module)
    enrollment.present? && enrollment.module_completed?(course_module.id)
  end

  def course_completed?(enrollment)
    enrollment.present? && enrollment.course_completed?
  end

  def next_quiz_path(course, course_module, current_quiz)
    next_quiz = course_module.next_quiz(current_quiz)

    return if next_quiz.blank?

    course_module_quiz_path(course, course_module, next_quiz)
  end

  def prev_quiz_path(course, course_module, current_quiz)
    prev_quiz = course_module.prev_quiz(current_quiz)

    return if prev_quiz.blank?

    course_module_quiz_path(course, course_module, prev_quiz)
  end

  def answer_text(answer)
    return '' if answer.blank?

    quiz = answer.quiz
    correct_answer = quiz.send(:"option_#{quiz.answer.downcase}")
    your_answer = if answer.answer == 'skip'
                    'You have skipped this question'
                  else
                    quiz.send(:"option_#{answer.answer.downcase}")
                  end

    if answer.status == QuizAnswer::STATUS_MAPPING[:correct]
      "You have answered #{your_answer} and your answer is correct"
    elsif answer.status == QuizAnswer::STATUS_MAPPING[:incorrect]
      "You have answered #{your_answer} and the answer is wrong. Correct answer is #{correct_answer}"
    else
      'You have skipped this question'
    end
  end

  def lessons_in_order(course_module)
    records_in_order(course_module.lessons, course_module.lessons_in_order)
  end

  def quizzes_in_order(course_module)
    records_in_order(course_module.quizzes, course_module.quizzes_in_order)
  end

  def modules_in_order(course)
    records_in_order(course.course_modules, course.course_modules_in_order)
  end

  def options_for_duration
    {
      none: 'None',
      one_day: '1 Day',
      two_days: '2 Days',
      one_week: '1 Week',
      two_weeks: '2 Weeks',
      one_month: '1 Month'
    }.invert
  end

  def current_module?(course_module, enrollment)
    course_module.id == enrollment&.current_module_id
  end

  def current_lesson?(lesson, enrollment)
    lesson.id == enrollment&.current_lesson_id
  end

  def position_of_quiz(course_module, quiz)
    course_module.quizzes_in_order.index(quiz.id) + 1
  end

  def quiz_position_text(course_module, quiz)
    "#{position_of_quiz(course_module, quiz)}/#{course_module.quizzes_count}"
  end

  def updated_tags_query_params(tag)
    url_for(request.query_parameters.merge(tags: params[:tags] - [tag]))
  end

  def score_earned_for_module(enrollment, course_module)
    enrollment.present? ? enrollment.score_earned_for(course_module) : 0
  end

  def delete_tooltip_message(course)
    if course.published?
      t('course.cannot_delete_published')
    else
      t('course.cannot_delete_enrolled')
    end
  end

  private

  def partner_metrics
    # probably cache this in a short term basis rather than on demand memoization
    @partner_metrics ||= PartnerMetrics.new(current_user.learning_partner)
  end
end
