# frozen_string_literal: true

module Api
  module Internal
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :set_back_link
      skip_before_action :set_active_nav
      skip_before_action :proceed_to_onboarding_steps, raise: false

      rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
      rescue_from Faraday::Error, with: :render_upstream_error

      before_action :require_privileged_user!

      private

      def authenticate_user!
        render json: { error: 'Unauthorized' }, status: :unauthorized unless user_signed_in?
      end

      def require_privileged_user!
        render json: { error: 'Forbidden' }, status: :forbidden unless current_user&.privileged_user?
      end

      def render_forbidden
        render json: { error: 'Forbidden' }, status: :forbidden
      end

      def render_upstream_error(err)
        upstream_status = err.response&.dig(:status) || 502
        render json: { error: err.message }, status: upstream_status
      end

      def neo_ai
        @neo_ai ||= NeoAi::Client.new
      end
    end
  end
end
