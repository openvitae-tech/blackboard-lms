# frozen_string_literal: true

module Api
  module Internal
    class UsersController < ApplicationController
      skip_before_action :verify_authenticity_token

      FIXTURES_PATH = File.expand_path('../../../../../fixtures/api', __dir__)

      def me
        render json: File.read(File.join(FIXTURES_PATH, 'users', 'me.json'))
      end
    end
  end
end
