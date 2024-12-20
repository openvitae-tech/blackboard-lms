# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vimeo::UploadVideoService do
  subject { described_class.instance }

  let(:lesson) { create :lesson }
  let(:local_content) { lesson.local_contents.first }

  describe '#upload_to_vimeo' do
    before do
      stub_vimeo_generate_upload_url_api(local_content.video.blob)

      allow_any_instance_of(ActiveStorage::Blob).to receive(:url).and_return('http://localhost:3000/sample_video.mp4')
      stub_request(:get, 'http://localhost:3000/sample_video.mp4')
        .to_return(status: 200)

      stub_vimeo_video_upload_api
    end

    it 'uploads video to vimeo' do
      response = subject.upload_video(local_content.video.blob, local_content.id)
      vimeo_video_url = local_content.video.blob.metadata['url']
      local_content.reload

      expect(response).to be_a(Net::HTTPOK)
      expect(vimeo_video_url).to eq('https://vimeo.com/1234')
      expect(local_content.status).to eq('complete')
    end
  end
end
