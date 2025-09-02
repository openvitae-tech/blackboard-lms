# frozen_string_literal: true

module Api
  module V1
    class OtpsController < ApplicationController
      layout false

      skip_before_action :authenticate_user!
      before_action :set_api_version

      def create
        service = Auth::OtpService.new(params[:phone])
        otp = service.generate_otp
        render json: { otp: }
      end

      def generate
        create
      end

      def verify
        service = Auth::OtpService.new(params[:phone])

        if service.verify_otp(params[:otp])
          render json: { success: true }
        else
          render json: { success: false }, status: :bad_request
        end
      end

      private

      def set_api_version
        @api_version = params[:controller].split("/")[1]
      end
    end
  end
end
