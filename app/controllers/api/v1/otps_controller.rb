# frozen_string_literal: true

module Api
  module V1
    class OtpsController < ApiController
      def generate
        service = Auth::OtpService.new(generate_auth_params[:phone], name: generate_auth_params[:name])
        service.generate_otp
        render json: { success: true }, status: :ok
      end

      def verify
        service = Auth::OtpService.new(params[:phone])

        if service.verify_otp(verify_auth_params[:otp])
          render json: { success: true }, status: :ok
        else
          render json: { success: false }, status: :bad_request
        end
      end

      private

      def generate_auth_params
        params.permit(:phone, :name)
      end

      def verify_auth_params
        params.permit(:phone, :otp)
      end
    end
  end
end
