# frozen_string_literal: true

module ContentStudio
  module ClassroomKits
    class StructureController < ApplicationController
      def show
        @kit = ApiClient.get_classroom_kit(params[:id])
      rescue Faraday::Error => e
        Rails.logger.error("[ContentStudio] kit structure#show failed: #{e.message}")
        head :service_unavailable
      end
    end
  end
end
