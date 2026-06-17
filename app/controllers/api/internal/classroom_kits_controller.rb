# frozen_string_literal: true

module Api
  module Internal
    class ClassroomKitsController < BaseController
      def create
        title = params[:title]
        data = neo_ai.create_kit(
          files: params[:files],
          components: Array(params[:components])
        )
        kit_id = data['kit_id']
        Rails.cache.write("kit_title_#{kit_id}", title, expires_in: 90.days) if title.present?
        render json: { kit_id: kit_id }
      end

      def show
        data = neo_ai.get_kit(params[:id])
        render json: data
      end
    end
  end
end
