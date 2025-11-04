# frozen_string_literal: true

class Transcript < ApplicationRecord
  belongs_to :local_content

  validates :start_at, :end_at, :text, presence: true
  validate :start_time_must_be_before_end_time

  # rubocop:disable Rails/SkipsModelValidations
  def self.update_with_transaction(local_content, data)
    Transcript.transaction do
      local_content.transcripts.destroy_all
      timestamp = Time.current
      records = data.map do |entry|
        {
          local_content_id: local_content.id,
          text: entry['text'],
          start_at: entry['start_at'],
          end_at: entry['end_at'],
          created_at: timestamp,
          updated_at: timestamp
        }
      end
      Transcript.insert_all!(records)
    end
  end
  # rubocop:enable Rails/SkipsModelValidations

  private

  def start_time_must_be_before_end_time
    return if start_at.blank? || end_at.blank?

    errors.add(:base, I18n.t('transcript.start_time_must_be_before_end_time')) if start_at >= end_at
  end
end
