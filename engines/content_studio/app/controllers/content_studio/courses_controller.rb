# frozen_string_literal: true

module ContentStudio
  class CoursesController < ApplicationController
    def index
      clear_wizard_session
      @stats = ApiClient.course_stats

      in_progress_courses = ApiClient.list_courses_by_status('in_progress')
      in_progress_kits    = ApiClient.list_classroom_kits_by_status('in_progress')
      completed_courses   = ApiClient.list_courses_by_status('completed')
      completed_kits      = ApiClient.list_classroom_kits_by_status('completed')

      @in_progress_creations = sort_creations(in_progress_courses + in_progress_kits)
      @completed_creations   = sort_creations(completed_courses + completed_kits)
    end

    private

    def sort_creations(items)
      items.sort_by { |item| item.created_at.to_s }.reverse
    end

    def clear_wizard_session
      session.delete(:wizard_file_urls)
      session.delete(:wizard_file_metadata)
      session.delete(:wizard_languages)
      session.delete(:wizard_branding)
    end
  end
end
