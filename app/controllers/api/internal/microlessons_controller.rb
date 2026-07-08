# frozen_string_literal: true

module Api
  module Internal
    class MicrolessonsController < BaseController
      def show
        data = neo_ai.get_microlesson(params[:id])
        render json: data
      end

      def create
        data = neo_ai.create_microlesson(
          title: params[:title],
          description: params[:description],
          template_id: params[:template_id],
          logo_url: params[:logo_url],
          bg_type: params[:bg_type].presence || 'video'
        )
        render json: { microlesson_id: data['microlesson_id'] }
      end
    end
  end
end
