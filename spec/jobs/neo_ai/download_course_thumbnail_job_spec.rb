# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NeoAi::DownloadCourseThumbnailJob do
  let(:course) { create(:course) }
  let(:thumbnail_url) { 'https://neo.ai/thumb.jpg' }
  let(:image_data) { 'fake-image-data' }

  before do
    stub_request(:get, thumbnail_url).to_return(body: image_data, status: 200)
  end

  describe '#perform' do
    it 'attaches the downloaded image to course banner' do
      described_class.new.perform(course.id, thumbnail_url)
      expect(course.reload.banner).to be_attached
    end

    it 'does nothing when the course does not exist' do
      expect { described_class.new.perform(-1, thumbnail_url) }.not_to raise_error
    end

    it 'does nothing when thumbnail_url is blank' do
      described_class.new.perform(course.id, '')
      expect(course.reload.banner).not_to be_attached
    end
  end
end
