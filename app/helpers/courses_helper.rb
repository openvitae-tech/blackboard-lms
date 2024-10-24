# frozen_string_literal: true

module CoursesHelper
  def course_banner(course)
    return course.banner if course && course.banner.present?

    'course.jpeg'
  end

  def course_banner_thumbnail(course)
    return course.banner if course&.banner&.variant(resize_to_limit: [nil, 200])

    'course_thumbnail.jpeg'
  end

  def course_banner_thumbnail_vertical(course)
    return course.banner if course&.banner&.variant(resize_to_limit: [140, nil])

    'course_thumbnail.jpeg'
  end

  def course_description(course, limit = nil)
    if limit.present?
      sanitize course.rich_description&.to_plain_text[0..limit]
    else
      course.rich_description
    end
  end

  def next_lesson_path(course, course_module, current_lesson)
    next_lesson = course_module.next_lesson(current_lesson)

    if next_lesson.blank?
      course_module = course_module.next_module
      next_lesson = course_module.first_lesson if course_module.present?
    end

    return unless next_lesson.present?

    course_module_lesson_path(course, course_module, next_lesson)
  end

  def prev_lesson_path(course, course_module, current_lesson)
    prev_lesson = course_module.prev_lesson(current_lesson)

    if prev_lesson.blank?
      course_module = course_module.prev_module
      prev_lesson = course_module.last_lesson if course_module.present?
    end

    return unless prev_lesson.present?

    course_module_lesson_path(course, course_module, prev_lesson)
  end

  def enroll_count(course)
    number_with_delimiter(course.enrollments_count)
  end

  def modules_count(course)
    pluralize(course.course_modules_count, 'module')
  end

  def lessons_count(course_module)
    pluralize(course_module.lessons.count, 'lesson')
  end

  def course_duration(course)
    duration_in_words(course.duration)
  end

  def duration_in_words(duration)
    if duration > 60
      in_hours = duration.in_hours
      in_minutes = duration - (in_hours * 60)
      "#{in_hours} hr #{in_minutes} min"
    else
      "#{duration} min"
    end
  end

  def lesson_completed?(enrollment, lesson)
    enrollment.completed_lessons.include? lesson.id
  end

  def module_completed?(enrollment, course_module)
    enrollment.module_completed?(course_module.id)
  end

  def course_completed?(enrollment)
    enrollment.course_completed?
  end

  def next_quiz_path(course, course_module, current_quiz)
    next_quiz = course_module.next_quiz(current_quiz)

    return unless next_quiz.present?

    course_module_quiz_path(course, course_module, next_quiz)
  end

  def prev_quiz_path(course, course_module, current_quiz)
    prev_quiz = course_module.prev_quiz(current_quiz)

    return unless prev_quiz.present?

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
      one_day_: '1 Day',
      two_days: '2 Days',
      one_week: '1 Week',
      two_weeks: '2 Weeks',
      one_month: '1 Month',
      custom: 'Custom'
    }.invert
  end
end
