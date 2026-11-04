# frozen_string_literal: true

module ContentStudio
  module MicrolessonScenesConcern
    extend ActiveSupport::Concern

    MOCK_SCENES = [
      {
        'title' => 'Setting the Scene',
        'narration' => 'Every great story starts with a moment of stillness — a breath before ' \
                       'the plunge. In this opening scene, we establish the world and invite the audience in.',
        'status' => 'PENDING',
        'video_url' => nil,
        'thumbnail_url' => nil
      },
      {
        'title' => 'The Challenge Appears',
        'narration' => 'Conflict is the engine of learning. Here we introduce the core problem ' \
                       'your audience will need to solve, making the stakes clear and the path forward uncertain.',
        'status' => 'PENDING',
        'video_url' => nil,
        'thumbnail_url' => nil
      },
      {
        'title' => 'Exploring the Solution',
        'narration' => 'Armed with curiosity, we unpack the tools and thinking needed to move ' \
                       'forward. Each step is deliberate, each idea builds on the last.',
        'status' => 'PENDING',
        'video_url' => nil,
        'thumbnail_url' => nil
      },
      {
        'title' => 'Putting It Together',
        'narration' => 'The pieces fall into place. In this closing scene we consolidate the ' \
                       'journey — summarising key insights and leaving the learner with a clear takeaway.',
        'status' => 'PENDING',
        'video_url' => nil,
        'thumbnail_url' => nil
      }
    ].freeze

    private

    def fetch_micro_scenes(microlesson_id)
      data = ApiClient.get_microlesson(microlesson_id)
      micro_scenes_from(data)
    rescue StandardError => e
      raise if Rails.env.production?

      Rails.logger.warn("[ContentStudio] get_microlesson failed, using mock scenes: #{e.message}")
      MOCK_SCENES
    end

    def micro_scenes_from(data)
      data['micro_scenes'].presence || (Rails.env.production? ? raise('micro_scenes missing') : MOCK_SCENES)
    end
  end
end
