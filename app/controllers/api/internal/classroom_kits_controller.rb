# frozen_string_literal: true

module Api
  module Internal
    class ClassroomKitsController < BaseController
      def index
        kits = neo_ai.list_kits
        filtered = filter_by_studio_status(kits, params[:studio_status])
        limit = params[:limit]&.to_i
        filtered = filtered.first(limit) if limit&.positive?
        render json: filtered.map { |k| serialize_kit(k) }
      end

      def show
        data = neo_ai.get_kit(params[:id])
        render json: data
      end

      def create
        title = params[:title]
        data = neo_ai.create_kit(
          files: params[:files],
          components: Array(params[:components]),
          title: title
        )
        kit_id = data['kit_id']
        Rails.cache.write("kit_title_#{kit_id}", title, expires_in: 90.days) if title.present?
        render json: { kit_id: kit_id }
      end

      def destroy
        neo_ai.delete_kit(params[:id])
        head :no_content
      rescue Faraday::BadRequestError
        render json: { error: t('content_studio.classroom_kits.discard.locked') }, status: :unprocessable_entity
      end

      def save
        authorize :classroom_kit, :save?
        NeoAi::ClassroomKitSaveService.new(neo_ai).call(
          params[:id],
          learning_partner_id: current_user.learning_partner_id
        )
        render json: { status: :ok }
      end

      private

      def filter_by_studio_status(kits, status)
        case status.presence
        when 'completed'   then kits.select { |k| k['status']&.upcase == 'COMPLETED' }
        when 'in_progress' then kits.reject { |k| k['status']&.upcase == 'COMPLETED' }
        else kits
        end
      end

      def serialize_kit(data)
        {
          id: data['kit_id'],
          title: data['title'],
          status: data['status'],
          stage: data['stage'],
          thumbnail_url: data['thumbnail_url'],
          doc_count: data['num_components'].to_i,
          created_at: data['created_at'],
          updated_at: nil,
          expires_at: data['expires_at'],
          components: []
        }
      end
    end
  end
end
