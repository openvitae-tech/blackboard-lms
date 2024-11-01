# frozen_string_literal: true

class LocalContent < ApplicationRecord
  attr_accessor :blob_id

  SUPPORTED_LANGUAGES = {
    english: 'English',
    hindi: 'Hindi',
    tamil: 'Tamil',
    marathi: 'Marathi',
    bengali: 'Bengali',
    kannada: 'Kannada',
    malayalam: 'Malayalam'
  }.freeze

  DEFAULT_LANGUAGE = SUPPORTED_LANGUAGES[:english]

  belongs_to :lesson

  has_one_attached :video

  before_create :attach_blob_to_video
  after_create :upload_to_vimeo, if: -> { Rails.env.production? }

  validates :lang, presence: true
  validate :presence_of_blob_id

  private

  def presence_of_blob_id
    errors.add(:base, I18n.t('local_content.video_not_found', lang:)) if blob_id.empty?
  end

  def attach_blob_to_video
    blob = ActiveStorage::Blob.find(blob_id)
    video.attach(blob)
  end

  def upload_to_vimeo
    UploadVideoToVimeoJob.perform_async(video.blob.id)
  end
end
