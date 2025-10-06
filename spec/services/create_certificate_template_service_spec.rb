# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateCertificateTemplateService do
  subject { described_class.instance }

  let(:learning_partner) { create(:learning_partner) }

  describe '#generate' do
    before do
      @zip_file = Rails.root.join('spec/fixtures/files/certificate_template.zip')
    end

    it 'returns the unsaved template if name or template zip is blank' do
      template = subject.generate(learning_partner, { name: '', template_zip: '' })

      expect(template).to be_a(CertificateTemplate)
      expect(template.persisted?).to be false
    end

    it 'build certificate template' do
      template = subject.generate(learning_partner, { name: 'Test Template', template_zip: @zip_file })

      expect(template.assets.count).to eq(4)
      expect(template.html_file).to be_attached
    end

    it 'returns error if template is missing required template variables' do
      # rubocop:disable Style/FormatStringToken
      html = <<~HTML
        <div>
          Certificate for %{CandidateName} completing %{CourseName}.
        </div>
      HTML
      # rubocop:enable Style/FormatStringToken

      zip_tempfile = Tempfile.new(['invalid_template', '.zip'])
      Zip::OutputStream.open(zip_tempfile.path) do |zos|
        zos.put_next_entry('index.html')
        zos.write(html)
      end

      template = subject.generate(
        learning_partner,
        { name: 'Invalid Template', template_zip: zip_tempfile }
      )

      expect(template.errors.full_messages.to_sentence).to eq('HTML template is missing required variables: IssueDate')
    end
  end
end
