# frozen_string_literal: true

module ContentStudio
  class CoursesController < ApplicationController
    def index
      clear_wizard_session
      @stats = ApiClient.course_stats
      @in_progress = ApiClient.list_courses_by_status('in_progress')
      @completed = ApiClient.list_courses_by_status('completed')
    end

    private

    def clear_wizard_session
      session.delete(:wizard_file_urls)
      session.delete(:wizard_file_metadata)
      session.delete(:wizard_languages)
      session.delete(:wizard_branding)
    end
  end
end
