# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lessons::UpdateService do
  subject { described_class.instance }

  let(:lesson) { create :lesson }

  describe '#update_lesson' do
    it 'Update lesson' do
      blob = ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/fixtures/files/sample_video.mp4').open,
        filename: 'sample_video.mp4',
        content_type: 'video/mp4'
      )

      expect do
        subject.update_lesson!(lesson, lesson_params(blob))
      end.to change(LocalContent, :count).by(2)
    end
  end

  private

  def lesson_params(blob)
    {
      title: Faker::Lorem.sentence,
      rich_description: Faker::Lorem.sentence(word_count: 5),
      video_streaming_source: 'local',
      duration: 100,
      local_contents_attributes: {
        '1' => { blob_id: blob.id, lang: 'malayalam' }
      }
    }
  end
end
