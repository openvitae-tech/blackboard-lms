# frozen_string_literal: true

module ContentStudio
  class CoursesController < ApplicationController
    def index
      @stats = ApiClient.course_stats
      @to_be_verified = ApiClient.list_courses_by_status('to_be_verified')
      @verified = ApiClient.list_courses_by_status('verified')
      @published = ApiClient.list_courses_by_status('published')
    end
  end
end
