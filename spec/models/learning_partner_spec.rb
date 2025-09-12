# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LearningPartner, type: :model do
  let(:learning_partner) { create :learning_partner }

  before do
    @parent_team = create :team, learning_partner:
  end

  describe '#name' do
    it 'is not valid without name' do
      learning_partner.name = ''
      expect(learning_partner).not_to be_valid
      expect(learning_partner.errors.full_messages.to_sentence).to include(t('cant_blank',
                                                                             field: 'Name'))
    end

    it 'is invalid if name is too short' do
      learning_partner.name = 'a'
      expect(learning_partner).not_to be_valid
      expect(learning_partner.errors.full_messages.to_sentence).to eq('Name is too short (minimum is 2 characters)')
    end
  end

  describe '#content' do
    it 'is invalid when content exceeds the maximum length' do
      learning_partner.content = 'a' * 4097
      expect(learning_partner).not_to be_valid
      expect(learning_partner.errors.full_messages.to_sentence)
        .to eq('Content is too long (maximum is 4096 characters)')
    end
  end

  describe '#supported_countries' do
    it 'is not valid without supported_countries' do
      learning_partner.supported_countries = []
      expect(learning_partner).not_to be_valid
      expect(learning_partner.errors.full_messages.to_sentence).to include(t('cant_blank',
                                                                             field: 'Supported countries'))
    end
  end

  describe '#parent_team' do
    before do
      @child_team_one = create :team, learning_partner:, parent_team: @parent_team
      @child_team_two = create :team, learning_partner:, parent_team: @parent_team
    end

    it 'returns the parent team' do
      expect(@child_team_two.parent_team.id).to eq(@parent_team.id)
    end
  end

  describe '#acceptable_logo' do
    it 'allows valid image formats and sizes' do
      learning_partner.logo.attach(io: Rails.root.join('spec/files/less_than_1_mb.jpg').open,
                                   filename: 'less_than_1_mb.jpg', content_type: 'image/jpg')
      expect(learning_partner).to be_valid
    end

    it 'rejects non-image file types' do
      learning_partner.logo.attach(io: Rails.root.join('spec/files/sample.pdf').open,
                                   filename: 'sample.pdf', content_type: 'text/pdf')
      expect(learning_partner).not_to be_valid
      expect(learning_partner.errors.full_messages.to_sentence).to eq('Logo must be a JPEG, JPG or PNG')
    end

    it 'rejects large files' do
      allow(learning_partner.logo).to receive(:blob)
        .and_return(instance_double(ActiveStorage::Blob,
                                    byte_size: 2.megabytes, content_type: 'image/jpeg'))

      expect(learning_partner).not_to be_valid
      expect(learning_partner.errors.full_messages.to_sentence).to eq('Logo is too big')
    end
  end

  describe '#acceptable_banner' do
    it 'allows valid image formats and sizes' do
      learning_partner.banner.attach(io: Rails.root.join('spec/files/less_than_1_mb.jpg').open,
                                     filename: 'less_than_1_mb.jpg', content_type: 'image/jpg')
      expect(learning_partner).to be_valid
    end

    it 'rejects non-image file types' do
      learning_partner.banner.attach(io: Rails.root.join('spec/files/sample.pdf').open,
                                     filename: 'sample.pdf', content_type: 'text/pdf')
      expect(learning_partner).not_to be_valid
      expect(learning_partner.errors.full_messages.to_sentence).to eq('Banner must be a JPEG, JPG or PNG')
    end

    it 'rejects large files' do
      allow(learning_partner.banner).to receive(:blob)
        .and_return(instance_double(ActiveStorage::Blob,
                                    byte_size: 2.megabytes, content_type: 'image/jpeg'))

      expect(learning_partner).not_to be_valid
      expect(learning_partner.errors.full_messages.to_sentence).to eq('Banner is too big')
    end
  end

  describe 'state transitions' do
    it 'is active when state is new' do
      expect(learning_partner.active?).to be true
    end

    it 'is deactivated when state is in-active' do
      learning_partner.update!(state: 'in-active')
      expect(learning_partner.deactivated?).to be true
    end

    it 'can be deactivated from active state' do
      learning_partner.deactivate
      expect(learning_partner.state).to eq('in-active')
    end

    it 'can be activated from deactivated state' do
      learning_partner.update(state: 'in-active')
      learning_partner.activate

      expect(learning_partner.state).to eq('new')
    end

    it 'raises error if trying to activate an already active partner' do
      expect { learning_partner.activate }.to raise_error(Errors::IllegalPartnerState)
    end

    it 'raises error if trying to deactivate an already inactive partner' do
      learning_partner.update(state: 'in-active')
      expect { learning_partner.deactivate }.to raise_error(Errors::IllegalPartnerState)
    end
  end

  describe '#supported_countries_must_be_valid' do
    it 'returns an error if unsupported country is provided' do
      learning_partner.supported_countries = ['invalid_country']
      expect(learning_partner).not_to be_valid
      expect(learning_partner.errors.full_messages.to_sentence)
        .to eq('Supported countries contains invalid counties: invalid_country')
    end
  end

  describe '#only_one_supported_country' do
    it 'returns an error if more than one supported country is provided' do
      learning_partner.supported_countries = %w[india usa]

      expect(learning_partner).not_to be_valid
      expect(learning_partner.errors.full_messages.to_sentence)
        .to include('Supported countries can only have one country')
    end
  end

  describe '#active_certificate_template' do
    before do
      @certificate_template = create(:certificate_template, learning_partner:, active: true)
    end

    it 'return active certificate template' do
      expect(learning_partner.active_certificate_template).to eq(@certificate_template)
    end
  end
end
