# frozen_string_literal: true

FactoryBot.define do
  factory :local_content, class: 'LocalContent' do
    lang { 'english' }
    after(:build) do |local_content|
      blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'sample_video.mp4')),
        filename: 'sample_video.mp4',
        content_type: 'video/mp4'
      )
      local_content.blob_id = blob.id
    end
  end
end
