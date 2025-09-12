# frozen_string_literal: true

FactoryBot.define do
  factory :course_certificate do
    issued_at { Time.zone.today }
    certificate_uuid { SecureRandom.uuid }
    user
    course

    after(:build) do |certificate|
      fixture_path = Rails.root.join('spec/fixtures/files/sample_course_certificate.pdf')

      certificate.file.attach(
        io: fixture_path.open,
        filename: "certificate-#{certificate.course.title}-#{certificate.user.name}.pdf",
        content_type: 'application/pdf'
      )

      file_contents = File.read(fixture_path)
      certificate.file_hash = Digest::SHA256.hexdigest(file_contents)
    end
  end
end
