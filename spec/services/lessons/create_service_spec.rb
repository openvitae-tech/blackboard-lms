# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lessons::CreateService do
  subject { described_class.instance }

  let(:course_module) { create :course_module }

  describe '#create_lesson' do
    it 'creates lesson' do
      allow(Lessons::PostProcessingService.instance).to receive(:process_local_contents)
      blob = ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/fixtures/files/sample_video.mp4').open,
        filename: 'sample_video.mp4',
        content_type: 'video/mp4'
      )

      expect do
        subject.create_lesson!(lesson_params(blob), course_module)
      end.to change(Lesson, :count).by(1).and change(LocalContent, :count).by(1)
      expect(Lessons::PostProcessingService.instance).to have_received(:process_local_contents)
    end
  end

  private

  def lesson_params(blob)
    {
      title: Faker::Lorem.sentence,
      rich_description: Faker::Lorem.sentence(word_count: 5),
      video_streaming_source: 'local',
      course_module_id: course_module.id,
      duration: 100,
      local_contents_attributes: [
        { blob_id: blob.id, lang: 'english' }
      ]
    }
  end
end
