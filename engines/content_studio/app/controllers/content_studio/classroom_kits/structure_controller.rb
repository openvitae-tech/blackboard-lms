# frozen_string_literal: true

module ContentStudio
  module ClassroomKits
    class StructureController < ApplicationController
      def show
        @kit = ApiClient.get_classroom_kit(params[:id])
      end
    end
  end
end
