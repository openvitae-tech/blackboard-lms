# frozen_string_literal: true

RSpec.describe 'Request spec for Embeds Videos', type: :request do
  let(:lesson) { create :lesson }
  let(:learning_partner) { create :learning_partner }
  let!(:scorm) { create :scorm, learning_partner: }

  before do
    @local_content = lesson.local_contents.first
  end

  describe 'GET /embeds/videos/:id' do
    it 'when scorm token and video is valid' do
      get embeds_video_path(@local_content.id), params: { token: scorm.token }

      expect(assigns[:local_content]).to eq(@local_content)
      expect(assigns[:scorm]).to eq(scorm)
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:show)
    end
  end

  it 'when scorm token is invalid' do
    get embeds_video_path(@local_content.id), params: { token: 'invalid' }

    expect(response.body).to eq('Invalid token')
  end

  it 'when scorm token is expired' do
    travel_to Time.zone.today + 4.months

    get embeds_video_path(@local_content.id), params: { token: scorm.token }

    expect(response.body).to eq('Invalid token')
  end

  it 'when local content does not exist' do
    get embeds_video_path('123'), params: { token: scorm.token }

    expect(assigns(:video_iframe)).to be_nil
  end
end
