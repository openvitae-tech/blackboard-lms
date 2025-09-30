# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CertificateTemplate, type: :model do
  let(:learning_partner) { create(:learning_partner) }
  let(:certificate_template) { create(:certificate_template, learning_partner:) }

  describe '#name' do
    it 'is not valid without name' do
      certificate_template.name = ''

      expect(certificate_template).not_to be_valid
      expect(certificate_template.errors.full_messages.to_sentence).to eq(t('cant_blank',
                                                                            field: 'Name'))
    end
  end

  describe '#html_content' do
    it 'is not valid without html_content' do
      certificate_template.html_content = ''

      expect(certificate_template).not_to be_valid
      expect(certificate_template.errors.full_messages.to_sentence).to include(t('cant_blank',
                                                                                 field: 'Html content'))
    end
  end

  describe '#only_one_active_template' do
    it 'is invalid if another active template exists for the same learning partner' do
      certificate_template.update(active: true)
      new_template = build(:certificate_template, learning_partner:, active: true)

      expect(new_template).not_to be_valid
      expect(new_template.errors.full_messages.to_sentence).to eq(
        'There can be only one active certificate template per learning partner'
      )
    end
  end

  describe '#must_have_exact_template_variables' do
    it 'raise error if required variables are missing' do
      new_template = build(
        :certificate_template,
        learning_partner: learning_partner,
        html_content: '<div>Certificate for %{CandidateName} on %{IssueDate}</div>' # rubocop:disable Style/FormatStringToken
      )

      expect(new_template).not_to be_valid
      expect(new_template.errors.full_messages.to_sentence).to eq(
        'Html content is missing required variables: CourseName'
      )
    end
  end

  describe '#validate_assets' do
    it 'is valid when asset format is valid and under 5MB' do
      certificate_template.assets.attach(
        io: StringIO.new('fake png data'),
        filename: 'image.png',
        content_type: 'image/png'
      )
      allow(certificate_template.assets.first.blob).to receive(:byte_size).and_return(1.megabyte)

      expect(certificate_template).to be_valid
    end

    it 'is not valid when asset is a PDF' do
      certificate_template.assets.attach(
        io: StringIO.new('fake pdf data'),
        filename: 'doc.pdf',
        content_type: 'application/pdf'
      )
      allow(certificate_template.assets.first.blob).to receive(:byte_size).and_return(1.megabyte)

      expect(certificate_template).not_to be_valid
      expect(certificate_template.errors[:assets]).to include('must be a PNG, JPEG or webp')
    end
  end
end
