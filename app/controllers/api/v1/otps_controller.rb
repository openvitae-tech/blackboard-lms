# frozen_string_literal: true

module Api
  module V1
    class OtpsController < ApiController
      before_action :set_phone_number

      # special case added for compatibility with framer
      def generate_or_verify
        params[:otp].present? ? verify : generate
      end

      def generate
        service = Auth::OtpService.new(@phone, name: generate_auth_params[:name])
        if service.generate_otp
          render json: { success: true }, status: :ok
        else
          render json: { success: false }, status: :bad_request
        end
      end

      def verify
        service = Auth::OtpService.new(@phone)

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

      def set_phone_number
        @phone = MobileNumber.new(value: generate_auth_params[:phone], country_code: AVAILABLE_COUNTRIES[:india][:code])
      end
    end
  end
end
