# frozen_string_literal: true

namespace :one_timer do
  desc 'Upload videos from s3 bucket to vimeo account'
  task upload_from_s3_to_vimeo: :environment do
    Rails.logger.info 'Uploading videos to vimeo'
  end
end
