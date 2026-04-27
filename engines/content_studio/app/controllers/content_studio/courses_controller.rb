# frozen_string_literal: true

module ContentStudio
  class CoursesController < ApplicationController
    def index
      clear_wizard_session
      @stats = ApiClient.course_stats
      @to_be_verified = ApiClient.list_courses_by_status('to_be_verified')
      @verified = ApiClient.list_courses_by_status('verified')
      @published = ApiClient.list_courses_by_status('published')
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
