# frozen_string_literal: true

class Assessment < ApplicationRecord
  belongs_to :user
  belongs_to :course

  STATUS = { pending: 0, in_progress: 1, completed: 2 }.freeze
  QUESTIONS_COUNT = 20
  PASS_PERCENTAGE = 50
  MAX_ATTEMPT = 2

  validate :validate_questions_count
  validates :status, inclusion: { in: STATUS.values }

  before_validation :build_questions, on: :create

  def encoded_id
    Base64.strict_encode64("#{created_at.to_i}-#{id}")
  end

  def retry!
    return if attempt >= MAX_ATTEMPT

    build_questions
    update(score: 0,
           current_question_index: 0,
           attempt: attempt.next,
           responses: {},
           status: STATUS[:pending],
           started_at: nil,
           completed_at: nil)
  end

  def start!
    update(score: 0, status: STATUS[:in_progress], started_at: Time.current, completed_at: nil)
  end

  def complete!
    update(score: correct_answers, status: STATUS[:completed], completed_at: Time.current)
  end

  def pending?
    status == STATUS[:pending]
  end

  def started?
    status == STATUS[:in_progress]
  end

  def completed?
    status == STATUS[:completed]
  end

  def score_percentage
    (score.to_f / questions.count * 100).round
  end

  def pass?
    completed? && score_percentage >= PASS_PERCENTAGE
  end

  def time_taken
    return 0 unless started_at

    diff_in_secs = ((completed_at || Time.current) - started_at) / 1.second
    diff_in_secs <= 20 * 60 ? (diff_in_secs / 60).round(2) : 20
  end

  private

  def build_questions
    self.questions = course.questions.verified.sample(QUESTIONS_COUNT).as_json
    self.status = STATUS[:pending]
  end

  def validate_questions_count
    return unless !questions.is_a?(Array) || questions.length != QUESTIONS_COUNT

    errors.add(:questions, "must contain exactly #{QUESTIONS_COUNT} questions")
  end

  def correct?(q_data)
    q_id = q_data['id'].to_s
    user_selection = responses[q_id]

    return false if user_selection.blank?

    correct_set = q_data['answers'].to_set
    user_set = Array.wrap(user_selection).to_set

    correct_set == user_set
  end

  def correct_answers
    total_correct = 0

    questions.each { |q_data| total_correct += 1 if correct?(q_data) }

    total_correct
  end
end
