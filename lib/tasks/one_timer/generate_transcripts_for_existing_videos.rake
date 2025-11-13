# frozen_string_literal: true

namespace :one_timer do
  desc 'Generate transcripts for existing videos'
  task generate_transcripts_for_existing_videos: :environment do
    Rails.logger.info 'Generating transcripts for existing videos'

    LocalContent.find_each do |local_content|
      ExtractAndSaveAudioJob.perform_async(local_content.id)
    end
  end
end
