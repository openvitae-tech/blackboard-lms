# frozen_string_literal: true

class LocalContent < ApplicationRecord
  attr_accessor :blob_id

  enum status: { pending: "pending", complete: "complete" }, _default: :pending

  SUPPORTED_LANGUAGES = {
    english: 'English',
    hindi: 'Hindi',
    tamil: 'Tamil',
    marathi: 'Marathi',
    bengali: 'Bengali',
    kannada: 'Kannada',
    malayalam: 'Malayalam',
    telugu: 'Telugu',
    assamese: 'Assamese'
  }.freeze

  DEFAULT_LANGUAGE = SUPPORTED_LANGUAGES[:english]

  belongs_to :lesson

  has_one_attached :video

  before_create :attach_blob_to_video

  before_create :set_status_to_complete
  validates :lang, presence: true
  validate :presence_of_blob_id

  private

  def presence_of_blob_id
    errors.add(:base, I18n.t('local_content.video_not_found', lang:)) if blob_id.blank? && !video.attached?
  end

  def attach_blob_to_video
    blob = ActiveStorage::Blob.find(blob_id)
    video.attach(blob)
  end

  def set_status_to_complete
    self.status = "complete" if Rails.env.development?
  end
end
