# frozen_string_literal: true

module Api
  module Internal
    module Courses
      class LessonsController < ApplicationController
        skip_before_action :verify_authenticity_token

        FIXTURES_PATH = File.expand_path('../../../../../../fixtures/api', __dir__)

        def show
          render json: File.read(File.join(FIXTURES_PATH, 'lesson.json'))
        end
      end
    end
  end
end
