# frozen_string_literal: true

class AssessmentQuestion
  attr_reader :id, :content, :options, :answers, :status, :responses

  def initialize(question, selected_options)
    @id = question['id']
    @content = question['content']
    @options = question['options']
    @answers = question['answers'].to_set
    @responses = Array.wrap(selected_options).to_set
    @status = selected_options.nil? ? nil : @answers == @responses
  end

  def skipped?
    status.nil?
  end

  def correct?
    status
  end

  def skipped_selection?(option)
    responses.exclude? option
  end

  def correct_selection?(option)
    !skipped_selection?(option) && answers.include?(option)
  end

  def dom_id
    "question_#{id}"
  end
end
