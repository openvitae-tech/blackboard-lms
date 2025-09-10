# frozen_string_literal: true

FactoryBot.define do
  factory :certificate_template, class: 'CertificateTemplate' do
    name { Faker::Lorem.word }

    # rubocop:disable Style/FormatStringToken
    html_content do
      <<~HTML
        <div>
          Certificate for %{CandidateName} completing %{CourseName} on %{IssueDate}.
        </div>
      HTML
    end
    # rubocop:enable Style/FormatStringToken

    learning_partner
  end
end
