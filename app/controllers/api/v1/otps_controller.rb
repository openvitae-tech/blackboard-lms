# frozen_string_literal: true

module Api
  module V1
    class OtpsController < ApiController
      def generate
        service = Auth::OtpService.new(params[:phone])
        otp = service.generate_otp
        render json: { otp: }
      end

      def verify
        service = Auth::OtpService.new(params[:phone])

        if service.verify_otp(params[:otp])
          render json: { success: true }
        else
          render json: { success: false }, status: :bad_request
        end
      end
    end
  end
end
