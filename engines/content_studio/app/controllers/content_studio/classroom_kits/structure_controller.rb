# frozen_string_literal: true

module ContentStudio
  module ClassroomKits
    class StructureController < ApplicationController
      def show
        @kit_id = params[:id]
      end
    end
  end
end
