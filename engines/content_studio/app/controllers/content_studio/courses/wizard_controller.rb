# frozen_string_literal: true

module ContentStudio
  module Courses
    class WizardController < ApplicationController
      def new
        @metadata = ApiClient.course_metadata
      end

      def create
        redirect_to root_path
      end
    end
  end
end
