# frozen_string_literal: true

class LocalContent < ApplicationRecord
  DEFAULT_LANGUAGE = 'english'

  SUPPORTED_LANGUAGES = {
    hindi: 'Hindi',
    tamil: 'Tamil',
    marathi: 'Marathi',
    bengali: 'Bengali',
    kannada: 'Kannada',
    malayalam: 'Malayalam',
    english: 'English'
  }.freeze

  belongs_to :lesson


  # Example code for choosing video service specifically in this model
  # has_one_attached :file
  # # Override the service for video files
  # def file_attachment
  #   file.service_name = :s3_video_store
  # end
end
