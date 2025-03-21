# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScormService::Video do
  let(:lesson) { create :lesson }
  let(:local_content) { lesson.local_contents.first }

  let(:scorm_video) { described_class.new(local_content.id, local_content.lang, 'www.example.com?token=123456') }

  describe '#id' do
    it 'returns the id of the local content' do
      expect(local_content.id).to eq(scorm_video.id)
    end
  end

  describe '#language' do
    it 'returns the language of the local content' do
      expect(local_content.lang).to eq(scorm_video.language)
    end
  end

  describe '#video_url' do
    it 'returns the video_url of the local content' do
      expect(scorm_video.video_url).to eq('www.example.com?token=123456')
    end
  end
end
