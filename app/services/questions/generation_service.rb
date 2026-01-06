# frozen_string_literal: true

module Questions
  class GenerationService
    include CommonsHelper

    attr_accessor :course, :transcripts, :course_materials

    MAX_QUESTIONS = 30

    def initialize(course)
      @course = course
      @transcripts = summarized_transcripts
      @course_materials = @course.materials.map(&:blob)
    end

    def generate_via_ai
      return [] unless generate?

      result = Integrations::Llm::Api.llm_instance(provider: :gemini)
                                     .generate_questions(MAX_QUESTIONS, transcripts, course_materials)
      return result.data['questions'] if result.ok?

      log_error_to_sentry("Questions generation failed for course #{@course.id}: #{result.data}")
      []
    end

    def generate?
      transcripts.present? || course_materials.present?
    end

    private

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
