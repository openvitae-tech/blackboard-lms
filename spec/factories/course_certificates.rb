# frozen_string_literal: true

FactoryBot.define do
  factory :course_certificate do
    issued_at { Time.zone.today }
    certificate_uuid { SecureRandom.uuid }
    user
    course

    after(:build) do |certificate|
      pdf_path = Rails.root.join('spec/fixtures/files/sample_course_certificate.pdf')
      thumbnail_path = Rails.root.join('spec/fixtures/files/sample_course_certificate.jpeg')

      certificate.file.attach(
        io: pdf_path.open,
        filename: "certificate-#{certificate.course.title}-#{certificate.user.name}.pdf",
        content_type: 'application/pdf'
      )

      certificate.certificate_thumbnail.attach(
        io: thumbnail_path.open,
        filename: "certificate-#{certificate.course.title}-#{certificate.user.name}.pdf",
        content_type: 'image/jpeg'
      )

      file_contents = File.read(pdf_path)
      certificate.file_hash = Digest::SHA256.hexdigest("#{file_contents}-#{SecureRandom.uuid}")
    end
  end
end
