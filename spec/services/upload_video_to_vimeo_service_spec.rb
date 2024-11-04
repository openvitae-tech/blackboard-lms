# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadVideoToVimeoService do
  let(:local_content) { create :local_content }

  describe '#upload_to_vimeo' do
    before do
      stub_vimeo_generate_upload_url_api(local_content.video.blob)

      allow_any_instance_of(ActiveStorage::Blob).to receive(:url).and_return('http://localhost:3000/sample_video.mp4')
      stub_request(:get, 'http://localhost:3000/sample_video.mp4')
        .to_return(status: 200)

      stub_vimeo_video_upload_api
    end

    it 'should_upload_video_to_vimeo' do
      response = upload_to_vimeo_service(local_content.video.blob).process
      vimeo_video_url = local_content.video.blob.metadata['url']

      expect(response).to be_a(Net::HTTPOK)
      expect(vimeo_video_url).to eq('https://vimeo.com/1234')
    end
  end

  private

  def upload_to_vimeo_service(blob)
    UploadVideoToVimeoService.new(blob)
  end
end