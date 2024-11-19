# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vimeo::DeleteVideoService do
  subject { described_class.instance }

  let(:lesson) { create :lesson }
  let(:local_content) { lesson.local_contents.first }

  describe '#delete_video' do
    before do
      video_id = '1234'
      stub_vimeo_delete_api(video_id)
    end

    it 'deletes video from vimeo' do
      response = subject.delete_video('https://vimeo.com/1234')
      expect(response).to be_a(Net::HTTPOK)
    end
  end
end
