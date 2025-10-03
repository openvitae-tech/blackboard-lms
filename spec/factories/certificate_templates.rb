# frozen_string_literal: true

FactoryBot.define do
  factory :certificate_template, class: 'CertificateTemplate' do
    name { Faker::Lorem.word }
    learning_partner

    after(:build) do |certificate_template|
      # rubocop:disable Style/FormatStringToken
      html = <<~HTML
        <div>
          Certificate for %{CandidateName} completing %{CourseName} on %{IssueDate}.
        </div>
      HTML
      # rubocop:enable Style/FormatStringToken

      certificate_template.html_file.attach(
        io: StringIO.new(html),
        filename: 'index.html',
        content_type: 'text/html'
      )
    end
  end
end
