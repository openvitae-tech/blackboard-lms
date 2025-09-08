# frozen_string_literal: true

class Api::ApiController < ActionController::API
  # this can be commented during development or local testing
  before_action :verify_auth_token!
  before_action :set_api_version

  private

  def set_api_version
    @api_version = params[:controller].split("/")[1]
  end

  def verify_auth_token!
    if params[:auth_token] != Rails.application.credentials.dig(:api_token)
      render json: {}, status: :unauthorized
    end
  end
end