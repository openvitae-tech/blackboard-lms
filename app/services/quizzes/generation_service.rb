# frozen_string_literal: true

module Quizzes
  class GenerationService
    attr_accessor :course_module, :transcripts

    MAX_QUIZ_QUESTIONS = 5

    def initialize(course_module)
      @course_module = course_module
      @transcripts = summarized_transcripts
    end

    def generate_via_ai
      return [] if transcripts.empty?

      result = Integrations::Llm::Api.llm_instance(provider: :gemini).generate_quiz(MAX_QUIZ_QUESTIONS, transcripts)
      return result.data['quizzes'] if result.ok?

      Rails.logger.error("Quiz generation failed: #{result.data}")
      []
    end

    def max_quiz_reached?
      course_module.quizzes.count >= MAX_QUIZ_QUESTIONS
    end

    def generate?
      transcripts.present? && !max_quiz_reached?
    end

    def tooltip
      if transcripts.blank?
        'quiz.generate.transcripts_missing'
      elsif max_quiz_reached?
        'quiz.generate.too_many_questions'
      else
        'quiz.generate.button'
      end
    end

    private

    def summerized_transcripts
      module_transcripts = course_module.lessons.includes(local_contents: :transcripts).collect do |lesson|
        content = lesson.local_contents.first
        {
          title: lesson.title,
          transcripts: (content && content.transcripts.pluck(:text).join(' ')) || ''
        }
      end
      module_transcripts.select { |lt| lt[:transcripts].present? }
    end
  end
end
