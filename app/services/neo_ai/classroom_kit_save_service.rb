# frozen_string_literal: true

module NeoAi
  class ClassroomKitSaveService
    def initialize(neo_ai_client)
      @neo_ai = neo_ai_client
    end

    def call(neo_ai_kit_id, learning_partner_id:)
      data = @neo_ai.get_kit(neo_ai_kit_id)
      title = Rails.cache.read("kit_title_#{neo_ai_kit_id}") || data['title']

      ActiveRecord::Base.transaction do
        kit = ClassroomKit.find_or_initialize_by(neo_ai_kit_id: neo_ai_kit_id)
        kit.update!(title: title, learning_partner_id: learning_partner_id)
        save_components(kit, data['components'] || [])
        kit
      end
    end

    private

    def save_components(kit, components)
      components.each do |comp|
        record = kit.classroom_kit_components
                    .find_or_initialize_by(neo_ai_component_id: comp['id'])
        record.update!(component_type: comp['type'], title: comp['title'])
      end
    end
  end
end
