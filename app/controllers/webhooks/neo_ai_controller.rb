class Webhooks::NeoAiController < ApplicationController
  before_action :authorize_webhook
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def create
    error = validate_params

    return render json: { error: error }, status: :bad_request if error

    SyncNeoAiCourseJob.perform_async(neo_ai_params[:course_id])
    head :ok
  end

  private

  def neo_ai_params
    params.permit(:course_id, :status)
  end

  def authorize_webhook
    client_secret = Rails.application.credentials.dig(:neo_ai, :api_access_token)

    if request.headers['x-client-secret'] != client_secret
      head :unauthorized
    end
  end

  def validate_params
    return "Parameter course_id is missing" if neo_ai_params[:course_id].blank?
    return "Parameter status is missing" if neo_ai_params[:status].blank?
    return "Course is not completed" unless neo_ai_params[:status] == "COMPLETE"

    nil
  end
end
