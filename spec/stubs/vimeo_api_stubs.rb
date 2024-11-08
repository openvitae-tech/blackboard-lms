# frozen_string_literal: true

def stub_vimeo_generate_upload_url_api(file)
  stub_request(
    :post,
    'https://api.vimeo.com/me/videos'
  ).with(headers: {
           'Authorization' => "bearer #{Rails.application.credentials.dig(:vimeo, :access_token)}",
           'Accept' => 'application/vnd.vimeo.*+json;version=3.4',
           'Content-Type' => 'application/json'
         }, body: {
           upload: {
             approach: 'tus',
             size: file.byte_size
           },
           name: file.filename.to_s
         }.to_json).to_return(
           status: 200,
           body: {
             upload: { upload_link: 'https://asia-files.tus.vimeo.com/files/vimeo-prod-src-tus-asia/1234' },
             link: 'https://vimeo.com/1234'
           }.to_json,
           headers: { 'Content-Type' => 'application/json' }
         )
end

def stub_vimeo_video_upload_api
  stub_request(
    :patch,
    'https://asia-files.tus.vimeo.com/files/vimeo-prod-src-tus-asia/1234'
  ).with(headers: {
           'Tus-Resumable' => '1.0.0',
           'Upload-Offset' => '0',
           'Content-Type' => 'application/offset+octet-stream'
         }).to_return(
           status: 200
         )
end
