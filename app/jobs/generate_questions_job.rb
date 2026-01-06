# frozen_string_literal: true

class GenerateQuestionsJob < BaseJob
  include CommonsHelper

  def perform(course_id, user_id, notification_link)
    return if course_id.blank? || user_id.blank?

    course = Course.find(course_id)
    user = User.find(user_id)
    saved_count = 0
    prev_question_ids = course.question_ids

    questions = Questions::GenerationService.new(course).generate_via_ai
    questions.each do |data|
      question = course.questions.new(content: data['question'],
                                      options: data['options'],
                                      answers: data['answers'],
                                      is_gen_ai: true)
      if question.save
        saved_count += 1
      else
        log_error_to_sentry("Failed to save generated question: #{question.errors.full_messages.join(', ')}")
      end
    end

    if saved_count.positive?
      response_on_success course:, user:, prev_question_ids:, notification_link:
    else
      response_on_failure course:
    end
  end

  private

  def response_on_success(course:, user:, prev_question_ids:, notification_link:)
    Question.where(id: prev_question_ids).destroy_all
    Turbo::StreamsChannel.broadcast_refresh_to(course, :questions)

    NotificationService.notify(user,
                               I18n.t('notifications.course.questions.title'),
                               format(I18n.t('notifications.course.questions.message'), title: course.title),
                               link: notification_link)
  end

  def response_on_failure(course:)
    Turbo::StreamsChannel.broadcast_replace_to(course, :questions,
                                               target: 'question-actions',
                                               partial: 'questions/action_buttons',
                                               locals: { course:, disabled: false })

    error_text = I18n.t('notifications.course.questions.generate_failed')
    Turbo::StreamsChannel.broadcast_replace_to(course, :questions,
                                               target: 'flash',
                                               partial: 'shared/components/flash',
                                               locals: { flash: { 'error' => error_text } })
  end
end
