# frozen_string_literal: true

module Questions
  class GenerationService
    include CommonsHelper

    attr_accessor :course, :transcripts, :couse_materials

    MAX_QUESTIONS = 30

    def initialize(course)
      @course = course
      @transcripts = summarized_transcripts
      @couse_materials = @course.materials.map(&:blob)
    end

    def generate_via_ai
      return [] unless generate?

      result = Integrations::Llm::Api.llm_instance(provider: :gemini)
                                     .generate_questions(MAX_QUESTIONS, transcripts, couse_materials)
      return result.data['questions'] if result.ok?

      log_error_to_sentry("Questions generation failed for course #{@course.id}: #{result.data}")
      []
    end

    def generate?
      transcripts.present? || couse_materials.present?
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

    def max_quiz_reached?
      course.questions.count >= MAX_QUESTIONS
    end

    def summarized_transcripts
      Lesson.where(course_module_id: course.course_module_ids).each_with_object([]) do |lesson, accumulated|
        next if lesson.transcript_text.blank?

        accumulated << {
          title: "#{lesson.course_module.title} : #{lesson.title}",
          transcripts: lesson.transcript_text
        }
      end
    end
  end
end
