# frozen_string_literal: true

module ContentStudio
  module Microlessons
    class StructureController < ApplicationController
      include MicrolessonScenesConcern

      def show
        @microlesson_id = params[:id]
        data = fetch_microlesson_data(@microlesson_id)

        @title = Rails.cache.read("ml_title_#{@microlesson_id}") || data['title']
        @duration_seconds = data['duration']
        @thumbnail_url = data['thumbnail_url']

        scenes = micro_scenes_from(data)
        @scenes = scenes.map.with_index(1) do |s, i|
          {
            number: i,
            total: scenes.size,
            title: s['title'],
            narration: s['narration'],
            video_url: s['video_url'],
            thumbnail_url: s['thumbnail_url'],
            status: s['status']
          }
        end

        completed = @scenes.count { |s| s[:video_url].present? }
        @percent_complete = @scenes.empty? ? 0 : (completed.to_f / @scenes.size * 100).round
      end

      private

      def fetch_microlesson_data(microlesson_id)
        ApiClient.get_microlesson(microlesson_id)
      rescue StandardError => e
        raise if Rails.env.production?

        Rails.logger.warn("[ContentStudio] get_microlesson failed, using empty data: #{e.message}")
        {}
      end
    end
  end
end
